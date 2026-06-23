# 9. CRON JOB, SOCKET.IO VÀ NOTIFICATION

## 9.1 Cron Jobs

### Tổng quan 4 Cron Jobs

| Tên Cron | File | Lịch chạy | Timezone | Chức năng |
|----------|------|-----------|---------|-----------|
| `autoCancelBookings` | `src/utils/cron-auto-cancel-bookings.js` | `*/1 * * * *` (mỗi 1 phút) | Asia/Ho_Chi_Minh | Hủy booking PENDING quá hạn |
| `autoCompleteBookings` | `src/utils/cron-auto-complete-bookings.js` | `*/1 * * * *` (mỗi 1 phút) | Asia/Ho_Chi_Minh | Hoàn thành booking đã qua giờ chơi |
| `matchmaker` | `src/utils/cron-matchmaker.js` | `*/1 * * * *` (mỗi 1 phút) | Asia/Ho_Chi_Minh | Ghép trận tự động + expire queue |
| `fixedScheduler` | `src/utils/cron-fixed-scheduler.js` | `5 0 * * *` (00:05 hàng ngày) + startup | Asia/Ho_Chi_Minh | Sinh booking từ lịch cố định |

---

### Cron 1: autoCancelBookings

**File**: `src/utils/cron-auto-cancel-bookings.js`  
**Lịch**: Mỗi phút `*/1 * * * *`  
**Gọi service**: `bookingService.autoCancelPendingBookings()`  
**Logic**:
- Quét tất cả Booking `status = PENDING`
- Nếu `created_at < now - threshold_minutes` → set `status = CANCELLED`, `cancelled_by = 'SYSTEM'`
- Cập nhật Payment liên quan → CANCELLED
- Gửi thông báo cho Customer

**Model bị ảnh hưởng**: Booking, Payment, Notification

**Guard**: `isRunning` flag, nếu lần trước chưa xong → bỏ qua lần này (`skipRun`)

---

### Cron 2: autoCompleteBookings

**File**: `src/utils/cron-auto-complete-bookings.js`  
**Lịch**: Mỗi phút `*/1 * * * *`  
**Gọi service**: `bookingService.autoCompleteFinishedBookings()`  
**Logic**:
- Quét tất cả Booking `status = CONFIRMED`
- Tính datetime kết thúc: `booking_date + end_minutes` (theo múi giờ Việt Nam)
- Nếu đã qua giờ kết thúc → `status = COMPLETED`
- Cập nhật MatchingSession liên kết (nếu có) → COMPLETED

**Model bị ảnh hưởng**: Booking, MatchingSession

**Output log**: `{ scannedBookings, completedBookings, completedMatchingSessions, durationMs }`

---

### Cron 3: matchmaker

**File**: `src/utils/cron-matchmaker.js`  
**Lịch**: Mỗi phút `*/1 * * * *`  
**Gọi service**: `matchingService.autoCancelUnmatched()` + `matchingService.runMatchmakerAlgorithm()`

**Logic**:
1. **Auto expire**: `autoCancelUnmatched()` hủy session OPEN quá lâu không đủ người, và expire queue SEARCHING quá hạn
2. **Match algorithm**: Với mỗi cặp `(sport, facility)`:
   - Lấy tất cả MatchQueue `status = SEARCHING, booking_date = today`
   - Nhóm các entry có thời gian chồng lặp, tiêu chí tương thích
   - Nếu tổng `member_count` đạt `group_size` → tạo booking + session + cập nhật queue → MATCHED
3. Log kết quả: `{ scannedGroups, matchedCount, activeSports, activeFacilities, expiredQueueCount, cancelledSessionCount }`

**Model bị ảnh hưởng**: MatchQueue, MatchingSession, Booking, Notification

---

### Cron 4: fixedScheduler

**File**: `src/utils/cron-fixed-scheduler.js`  
**Lịch chính**: `5 0 * * *` (00:05 hàng ngày)  
**Startup scan**: Chạy sau 5 giây khi server khởi động (setTimeout 5000ms)  
**Gọi service**: `fixedScheduleService.generateBookingsForRange()`

**Logic**:
1. `fixedScheduleRepository.findActiveSchedules()` — lấy tất cả FixedSchedule `status = ACTIVE`
2. `fixedScheduleService.getAdvanceGenerationRange()` — xác định range [today, today+N] (N cấu hình trong service)
3. Với mỗi schedule: `generateBookingsForRange(schedule, from, to)` — sinh booking cho range
4. Xử lý lỗi từng schedule độc lập

**Model bị ảnh hưởng**: FixedSchedule, Booking, MatchingSession (nếu type=MATCHING)

**Output log**: `{ activeSchedules, generatedBookings, skippedSchedules, failedSchedules, fromDate, toDate, durationMs }`

---

### Cron Status Tracking

**File**: `src/utils/cron-status.js`

Hệ thống tracking trạng thái từng cron:
- `registerJob(name, config)`: Đăng ký cron job
- `startRun(name, startedAt)`: Đánh dấu bắt đầu chạy
- `finishSuccess(name, summary, durationMs)`: Lưu kết quả thành công
- `finishError(name, error, durationMs)`: Lưu lỗi
- `skipRun(name, reason)`: Bỏ qua (khi đang chạy)

**API xem status**: `GET /health/cron` → trả về trạng thái tất cả cron

---

### Rủi ro khi deploy Render/free hosting

| Rủi ro | Mô tả | Giải pháp hiện có |
|--------|-------|-------------------|
| Server sleep | Render free tier sleep sau 15 phút không request | Dùng UptimeRobot ping `/health` mỗi 10 phút |
| Cron miss | Cron không chạy khi server đang sleep | Startup scan của fixedScheduler |
| Cron double-run | Scale horizontal gây chạy đôi | `isRunning` flag (chỉ hiệu quả single instance) |
| Late wake-up | Server wake-up muộn → cron bị delay | Acceptable delay < 1-2 phút |
| 00:05 cron miss | fixedScheduler có thể miss nếu server sleep lúc đó | Startup scan bù đắp khi server next wake up |

---

## 9.2 Socket.IO

### Khởi tạo

**File**: `src/services/socket-io.service.js` (7.5KB, class `SocketIOService`)  
**Khởi tạo trong**: `src/main.js`
```javascript
socketIOService.initialize(httpServer);
app.socketIO = socketIOService.io;
```

### Xác thực JWT qua Socket

```javascript
this.io.use((socket, next) => {
  const token = socket.handshake.auth.token || socket.handshake.query.token;
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  socket.userId = decoded.id;
  socket.userEmail = decoded.email;
  socket.userRole = decoded.role;
  next();
});
```

### Rooms (Phòng)

| Room | Điều kiện | Mô tả |
|------|-----------|-------|
| `user_{userId}` | Tất cả user đã login | Phòng riêng của mỗi user |
| `room_staff` | role === 'STAFF' | Tất cả staff |
| `room_admin` | role === 'ADMIN' | Tất cả admin |
| `room_matching_{sessionId}` | Khi emit `join_matching_room` | Phòng ghép trận cụ thể |

### Events được listen (Client → Server)

| Event | Mô tả |
|-------|-------|
| `join_matching_room` | `{ matchingSessionId }` — Tham gia room ghép trận |
| `leave_matching_room` | `{ matchingSessionId }` — Rời room ghép trận |
| `join` | `roomName` — Join room tùy chỉnh |
| `ping` | Kiểm tra kết nối |
| `disconnect` | Xử lý ngắt kết nối |

### Events được emit (Server → Client)

| Event | Phòng đích | Payload |
|-------|-----------|---------|
| `notification_received` | `user_{userId}` | `{ event, data: notification, timestamp }` |
| `new_notification` | `user_{userId}` | `notification object` |
| `notification_received` | `room_staff` | Thông báo cho tất cả STAFF |
| `new_notification` | `room_staff` | Thông báo STAFF |
| `notification_received` | `room_admin` | Thông báo cho tất cả ADMIN |
| `new_notification` | `room_admin` | Thông báo ADMIN |
| `matching_session_updated` | `room_matching_{id}` | `{ matchingSessionId, data: session, timestamp }` |
| `pong` | Socket cụ thể | Phản hồi ping |

### Các method emit của SocketIOService

| Method | Mô tả |
|--------|-------|
| `notifyUser(userId, notification)` | Gửi cho 1 user cụ thể |
| `notifyStaff(notification)` | Broadcast cho tất cả STAFF online |
| `notifyAdmin(notification)` | Broadcast cho tất cả ADMIN online |
| `notifyMatchingUpdate(sessionId, data)` | Cập nhật session ghép trận |
| `broadcastToUsers(userIds[], notification)` | Gửi cho nhiều users |
| `getOnlineUserCount()` | Số user đang online |
| `isUserOnline(userId)` | Kiểm tra user có online không |

### Mobile/Web có lắng nghe không?

- **Flutter**: Có `socket_io_client: ^2.0.3` trong pubspec, có service trong `lib/core/services/`
  - Lắng nghe `new_notification` và `notification_received`
  - Lắng nghe `matching_session_updated` khi ở trong màn hình matching
- **React Web**: Có `socket.io-client: ^4.7.5` trong package.json
  - Lắng nghe notification events trong notification pages
  - Realtime update booking/matching status

---

## 9.3 Notification/FCM

### Notification Model

**File**: `src/models/notification.model.js`  

Cấu trúc:
- `userId`: người nhận
- `title`, `content`: nội dung
- `type`: BOOKING | PAYMENT | SYSTEM | PROMOTION
- `audience`: CUSTOMER | STAFF | ADMIN | ALL
- `metadata`: bookingId, paymentId, matchingSessionId, link (deep link)
- `isRead`: trạng thái đọc

### Khi nào tạo thông báo

**File**: `src/services/notification.helper.js` (14.5KB)

| Sự kiện | Loại | Người nhận |
|---------|------|-----------|
| Booking mới PENDING | BOOKING | STAFF (facility) |
| Booking CONFIRMED | BOOKING | CUSTOMER |
| Booking CANCELLED (bởi STAFF/ADMIN) | BOOKING | CUSTOMER |
| Booking CANCELLED (bởi Cron/timeout) | BOOKING | CUSTOMER |
| Fixed Schedule PENDING_APPROVAL | SYSTEM | STAFF |
| Fixed Schedule ACTIVE (đã duyệt) | SYSTEM | CUSTOMER |
| Fixed Schedule REJECTED | SYSTEM | CUSTOMER |
| Payment SUCCESS (ZaloPay) | PAYMENT | CUSTOMER + STAFF |
| Matching member join (auto_approve=false) | SYSTEM | Host |
| Matching member APPROVED | SYSTEM | Member |
| Matching session FULL | SYSTEM | Tất cả members |
| Auto match thành công | SYSTEM | Tất cả queue players |

### FCM Push Notification

**File**: `src/services/fcm.service.js` (6.5KB)  
**Firebase Admin SDK**: `firebase-admin: ^13.10.0`  
**Khởi tạo**: `src/config/firebase-admin.js`

```javascript
// Cách gửi FCM
await admin.messaging().sendMulticast({
  tokens: user.fcmTokens,
  notification: { title, body },
  data: { type, bookingId, ... }
});
```

**Fallback**: Nếu Firebase chưa khởi tạo (không có serviceAccountKey) → ghi log cảnh báo, không crash

### Flutter nhận FCM

**Package**: `firebase_messaging: ^15.1.3`, `flutter_local_notifications: ^18.0.1`

- **Foreground**: Firebase Messaging `onMessage` stream → hiển thị local notification banner
- **Background**: Firebase Messaging background handler → notification tray
- **App terminated**: Firebase Messaging `getInitialMessage()` → navigate khi mở app

### serviceAccountKey — Cảnh báo

**File template**: `src/config/serviceAccountKey.json.template`  
**File thật**: `src/config/serviceAccountKey.json` (phải tạo thủ công, **KHÔNG commit vào git**)

**Biến môi trường FCM** (chỉ tên, không giá trị):
- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_CLIENT_EMAIL`: Service account email
- `FIREBASE_PRIVATE_KEY`: Service account private key

**Trạng thái hiện tại**:
- Firebase Admin đã cấu hình trong code
- FCM gửi được trong môi trường local (nếu có serviceAccountKey đúng)
- **Production**: Cần serviceAccountKey thật với project Firebase production của app

### Deep Link cho Notification

`metadata.link` trong Notification document dùng để navigate khi tap notification:
- `booking/{id}` → booking_detail_page
- `payment/{id}` → invoice_detail_page
- `matching/{id}` → matching_detail_page
- Chưa thấy cấu hình deep link scheme đầy đủ trong code Flutter

### Mock/Fallback

Hệ thống có cơ chế không crash khi FCM không hoạt động:
```javascript
// fcm.service.js
if (!admin.apps.length) {
  console.warn('[FCM] Firebase not initialized, skipping push notification');
  return;
}
```

Socket.IO vẫn hoạt động độc lập với FCM — realtime notification trong app không bị ảnh hưởng.
