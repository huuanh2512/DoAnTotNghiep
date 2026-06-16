# 9. CRON JOB, SOCKET.IO VÀ NOTIFICATION

## 9.1 Cron Jobs

### Tổng quan 4 Cron Job đang chạy

| Tên Cron | File | Lịch chạy | Chức năng | Model ảnh hưởng |
|----------|------|-----------|-----------|----------------|
| Auto Cancel Bookings | `src/utils/cron-auto-cancel-bookings.js` | `*/1 * * * *` (mỗi 1 phút) | Hủy booking PENDING đã quá giờ bắt đầu | Booking, Payment |
| Auto Complete Bookings | `src/utils/cron-auto-complete-bookings.js` | `*/1 * * * *` (mỗi 1 phút) | Chuyển booking CONFIRMED → COMPLETED sau khi hết giờ | Booking |
| Auto Matchmaker | `src/utils/cron-matchmaker.js` | `*/1 * * * *` (mỗi 1 phút) | Ghép tự động các queue entry tương thích, expire queue cũ | MatchQueue, MatchingSession |
| Fixed Scheduler | `src/utils/cron-fixed-scheduler.js` | `5 0 * * *` (00:05 hàng ngày) + khởi động | Sinh booking cho lịch cố định ACTIVE trong 7 ngày tới | FixedSchedule, Booking |

---

### Chi tiết từng Cron Job

#### 1. cron-auto-cancel-bookings.js
```
Schedule: */1 * * * *  (Mỗi 1 phút)
```
- Gọi `bookingService.autoCancelPendingBookings()`
- Logic: Tìm tất cả booking với `status: PENDING` mà `booking_date + start_minutes < NOW` (đã qua giờ bắt đầu)
- Cập nhật `status → CANCELLED`, `cancelled_by = 'system'`
- Gửi thông báo cho customer và staff
- **Rủi ro Render Free Tier:** Nếu server sleep, cron bị dừng → booking quá hạn không được tự hủy. Cần cấu hình Uptime Robot hoặc cron-job.org ping `/health` định kỳ.

#### 2. cron-auto-complete-bookings.js
```
Schedule: */1 * * * *  (Mỗi 1 phút)
```
- Gọi `bookingService.autoCancelPendingBookings()` (hoặc hàm tương tự cho complete)
- Logic: Tìm booking `status: CONFIRMED` mà `booking_date + end_minutes < NOW`
- Cập nhật `status → COMPLETED`
- **Rủi ro tương tự:** Server sleep → booking không được complete tự động

#### 3. cron-matchmaker.js
```
Schedule: */1 * * * *  (Mỗi 1 phút)
```
- **Bước 1:** Gọi `matchingService.autoCancelUnmatched()` – hủy session OPEN cũ, expire queue SEARCHING quá hạn
- **Bước 2:** Lấy danh sách tất cả Sport (active) và Facility (active)
- **Bước 3:** Vòng lặp: với mỗi cặp (sport, facility), với ngày hôm nay → gọi `matchingService.runMatchmakerAlgorithm()`
- Thuật toán: nhóm queue entries theo (booking_date, start_minutes, end_minutes, group_size, team_mode) → nếu đủ số lượng → tạo MatchingSession, gán thành viên, cập nhật queue MATCHED
- Gửi notification đến tất cả thành viên vừa được ghép

#### 4. cron-fixed-scheduler.js
```
Schedule: 5 0 * * *  (00:05 hàng ngày)
         + setTimeout 5 giây sau khi server khởi động (self-healing)
```
- Gọi `fixedScheduleRepository.findActiveSchedules()` – lấy FixedSchedule status ACTIVE
- Gọi `fixedScheduleService.getAdvanceGenerationRange()` – lấy range từ hôm nay đến 7 ngày tới
- Với mỗi lịch: gọi `generateBookingsForRange(schedule, fromDate, toDate)`
- Sinh booking cho từng ngày hợp lệ (không phải exception_date, đúng ngày trong tuần nếu WEEKLY)
- Sử dụng unique index để tránh sinh booking trùng (idempotent)

### Rủi ro khi deploy trên Render Free Tier:
1. **Server sleep:** Render Free Tier tắt server sau 15 phút không có request → tất cả cron bị dừng
2. **Giải pháp:** Dùng UptimeRobot hoặc cron-job.org ping endpoint `/health` mỗi 10-14 phút
3. **Cron Fixed Scheduler** có cơ chế self-healing (chạy ngay khi khởi động) → giúp bù bắt lịch bị bỏ qua
4. **Cron Matchmaker và Auto Cancel** cần server chạy liên tục để không miss booking

---

## 9.2 Socket.IO

### Khởi tạo
- **File:** `src/services/socket-io.service.js`
- Khởi tạo trong `src/main.js` → `socketIOService.initialize(httpServer)`
- Sử dụng `socket.io v4.7.2`
- Cho phép `allowEIO3: true` để tương thích với client cũ

### Xác thực
- Middleware xác thực JWT từ `socket.handshake.auth.token` hoặc `socket.handshake.query.token`
- Gắn `socket.userId`, `socket.userEmail`, `socket.userRole` sau khi xác thực

### Rooms (Phòng)

| Room | Thành viên | Mục đích |
|------|-----------|---------|
| `user_{userId}` | Mỗi user riêng | Nhận thông báo cá nhân |
| `room_staff` | Tất cả STAFF online | Nhận thông báo chung cho staff |
| `room_admin` | Tất cả ADMIN online | Nhận thông báo chung cho admin |
| `room_matching_{sessionId}` | Người trong session | Nhận cập nhật real-time về phiên ghép trận |

### Events Backend → Client (Emit)

| Event | Room | Payload | Khi nào |
|-------|------|---------|---------|
| `notification_received` | User room / Staff / Admin | `{ event, data, timestamp }` | Khi có thông báo mới |
| `new_notification` | User room / Staff / Admin | notification object | Khi có thông báo mới |
| `matching_session_updated` | `room_matching_{id}` | `{ matchingSessionId, data, timestamp }` | Khi có thay đổi trong session |
| `pong` | Socket cá nhân | - | Khi client gửi `ping` |

### Events Client → Backend (Listen)

| Event | Payload | Chức năng |
|-------|---------|-----------|
| `join_matching_room` | `{ matchingSessionId }` | Join vào phòng ghép trận để nhận cập nhật |
| `leave_matching_room` | `{ matchingSessionId }` | Rời phòng ghép trận |
| `join` | roomName | Join vào phòng bất kỳ |
| `ping` | - | Kiểm tra kết nối |
| `disconnect` | - | Ngắt kết nối, xóa socket khỏi userSockets map |

### Flutter có lắng nghe không?
- **Có:** `socket_io_client: ^2.0.3` trong pubspec.yaml
- Flutter kết nối Socket.IO với JWT token
- Lắng nghe `new_notification` và `notification_received` để cập nhật badge và danh sách thông báo
- Lắng nghe `matching_session_updated` trong trang chi tiết phiên ghép trận để real-time cập nhật thành viên

### React Web Admin có lắng nghe không?
- **Có:** `socket.io-client: ^4.7.5` trong package.json
- Web Admin kết nối Socket.IO để nhận thông báo mới
- STAFF nhận thông báo qua `room_staff`, ADMIN qua `room_admin`

### Phương thức trong SocketIOService:
- `notifyUser(userId, notification)` – Gửi đến user cụ thể
- `notifyStaff(notification)` – Gửi đến tất cả STAFF
- `notifyAdmin(notification)` – Gửi đến tất cả ADMIN
- `notifyMatchingUpdate(matchingSessionId, data)` – Gửi cập nhật phiên ghép trận
- `broadcastToUsers(userIds[], notification)` – Gửi đến nhiều user
- `getOnlineUserCount()` – Đếm user đang online
- `isUserOnline(userId)` – Kiểm tra user có online không

---

## 9.3 Notification / FCM

### Notification Model
- **File:** `models/notification.model.js`
- **Collection:** `notifications`
- **Các loại (type):** BOOKING, PAYMENT, SYSTEM, PROMOTION
- **Audience:** CUSTOMER, STAFF, ADMIN, ALL
- **Metadata:** Liên kết đến `bookingId`, `paymentId`, `matchingSessionId`, `link`
- **Compound Index:** `{ userId, audience, isRead, createdAt }` – Query nhanh thông báo chưa đọc

### Khi nào tạo thông báo:

| Sự kiện | Người nhận | Type |
|---------|-----------|------|
| Booking mới được tạo | STAFF của cơ sở | BOOKING |
| Booking được xác nhận | CUSTOMER | BOOKING |
| Booking bị hủy (bởi STAFF/system) | CUSTOMER | BOOKING |
| Booking auto-cancel | CUSTOMER | BOOKING |
| Phiên ghép trận mới | Users quan tâm (broadcast) | SYSTEM |
| Được ghép vào session (auto) | Tất cả thành viên | BOOKING |
| Member join/leave session | Host | BOOKING |
| Lịch cố định cần duyệt | STAFF/ADMIN | BOOKING |
| Lịch cố định được duyệt | CUSTOMER | BOOKING |
| Payment thành công | CUSTOMER | PAYMENT |
| Thông báo hệ thống | Theo audience | SYSTEM |

### Push FCM:
- **File:** `src/services/fcm.service.js`
- **Sử dụng:** Firebase Admin SDK (`firebase-admin: ^13.10.0`)
- **Cách hoạt động:**
  1. Tìm `fcmTokens[]` của user từ User model
  2. Gọi `messaging.sendEachForMulticast({ tokens, notification, data })`
  3. Xử lý kết quả: token không hợp lệ → tự động xóa khỏi user.fcmTokens
- **Cần cấu hình:** File `serviceAccountKey.json` thật (Firebase Service Account)
  - Hiện có `serviceAccountKey.json.template` – cần điền thông tin thật từ Firebase Console
  - **⚠️ KHÔNG commit file serviceAccountKey.json thật lên GitHub**

### Notification Helper:
- **File:** `src/services/notification.helper.js` (~15KB)
- Tổng hợp logic: Tạo notification record + gửi Socket.IO + gửi FCM
- Các hàm helper:
  - `createAndSendNotification(userId, title, content, type, metadata)` – Tạo + gửi cho 1 user
  - `notifyStaffNewBooking(booking)` – Thông báo STAFF có booking mới
  - `notifyCustomerBookingConfirmed(booking)` – Thông báo xác nhận booking
  - `notifyMatchingMembers(session, memberIds)` – Thông báo thành viên phiên ghép trận
  - (và nhiều hàm helper khác)

### Flutter nhận thông báo:
- **Online (foreground):** Socket.IO `new_notification` → cập nhật UI ngay
- **Background/Offline:** Firebase FCM `firebase_messaging` → hiển thị trong notification bar
- **Tap notification:** Có thể điều hướng đến màn hình liên quan qua deeplink trong metadata
- **flutter_local_notifications:** Hiển thị notification local khi app ở foreground

### Fallback / Mock:
- Nếu FCM không được cấu hình (`serviceAccountKey.json` không có) → FCM sẽ lỗi nhưng không crash toàn hệ thống (xử lý exception trong `fcm.service.js`)
- Socket.IO vẫn hoạt động bình thường độc lập với FCM
- Notification vẫn được lưu vào DB và có thể xem trong app
