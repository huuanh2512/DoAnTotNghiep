# 4. USE CASE, ACTIVITY DIAGRAM, SEQUENCE DIAGRAM

## 4.1 Use Case tổng quát

| Mã UC | Tên Use Case | Tác nhân | Mô tả | Điều kiện trước | Kết quả sau |
|-------|-------------|---------|-------|-----------------|-------------|
| UC01 | Đăng ký tài khoản | CUSTOMER | Tạo tài khoản với email/password | Chưa có tài khoản | Tài khoản được tạo, nhận JWT |
| UC02 | Đăng nhập | ALL | Xác thực email/password | Có tài khoản ACTIVE | Nhận access token + refresh token |
| UC03 | Làm mới token | ALL | Dùng refresh token lấy access mới | Có refresh token hợp lệ | Access token mới |
| UC04 | Quên mật khẩu | ALL | Gửi OTP về email | Email tồn tại | OTP được gửi |
| UC05 | Đặt lại mật khẩu | ALL | Nhập OTP + mật khẩu mới | OTP còn hạn | Mật khẩu được thay đổi |
| UC06 | Xem/cập nhật hồ sơ | ALL | Xem, chỉnh sửa thông tin cá nhân | Đã đăng nhập | Thông tin được cập nhật |
| UC07 | Xem danh sách cơ sở | ALL | Xem danh sách Facility | Đã đăng nhập | Danh sách Facility |
| UC08 | Xem danh sách sân | ALL | Xem sân theo Facility/Sport | Đã đăng nhập | Danh sách Court với slot |
| UC09 | Đặt sân | CUSTOMER | Chọn sân, ngày, slot giờ | Sân còn trống, đã đăng nhập | Booking PENDING được tạo |
| UC10 | Hủy booking | CUSTOMER | Hủy booking chưa hoàn thành | Booking đang PENDING/CONFIRMED | Booking CANCELLED |
| UC11 | Duyệt booking | STAFF/ADMIN | Xác nhận booking của khách | Booking đang PENDING | Booking CONFIRMED |
| UC12 | Thu ngân / Thanh toán | STAFF | Xác nhận thanh toán tại quầy | Payment đang PENDING | Payment SUCCESS |
| UC13 | Thanh toán ZaloPay | CUSTOMER | Thanh toán qua ZaloPay | Có payment PENDING | Payment SUCCESS |
| UC14 | Tạo lịch cố định | CUSTOMER | Đăng ký lịch đặt sân định kỳ | Sân tồn tại, đã đăng nhập | FixedSchedule PENDING_APPROVAL |
| UC15 | Duyệt lịch cố định | ADMIN/STAFF | Phê duyệt lịch cố định | FixedSchedule PENDING_APPROVAL | FixedSchedule ACTIVE |
| UC16 | Sinh booking từ lịch cố định | Hệ thống | Cron job tự động sinh booking | FixedSchedule ACTIVE | Booking mới được tạo |
| UC17 | Hủy một buổi lịch cố định | CUSTOMER | Đánh dấu ngoại lệ một ngày | FixedSchedule ACTIVE | exception_dates cập nhật |
| UC18 | Tạo phiên ghép trận | CUSTOMER | Tạo MatchingSession mở để tìm đối thủ | Có booking xác nhận hoặc muốn tạo mới | Session OPEN |
| UC19 | Tham gia phiên ghép trận | CUSTOMER | Join MatchingSession | Session OPEN, user chưa tham gia | Member PENDING/APPROVED |
| UC20 | Rời phiên ghép trận | CUSTOMER | Leave MatchingSession | Đang là member | Member xóa khỏi danh sách |
| UC21 | Ghép tự động | CUSTOMER | Vào hàng đợi, hệ thống ghép | Có queue entries tương thích | MatchingSession được tạo tự động |
| UC22 | Xem thông báo | ALL | Xem danh sách thông báo | Đã đăng nhập | Danh sách Notification |
| UC23 | Xem báo cáo hiệu suất | STAFF | Xem báo cáo sân | Đã đăng nhập với role STAFF | Báo cáo court performance |
| UC24 | Xem báo cáo nâng cao | ADMIN | Xem dashboard tổng hợp | Đã đăng nhập với role ADMIN | Báo cáo advanced performance |
| UC25 | Quản lý người dùng | ADMIN | Xem, phân quyền, khóa tài khoản | Đã đăng nhập với role ADMIN | Danh sách user, cập nhật role/status |
| UC26 | Upload ảnh | ALL | Upload avatar, ảnh sân | Đã đăng nhập | URL ảnh trên Cloudinary |
| UC27 | Đánh giá dịch vụ | CUSTOMER | Gửi review sau khi sử dụng sân | Booking COMPLETED | Review được tạo |
| UC28 | Gửi thông báo hệ thống | ADMIN | Broadcast thông báo đến users | Role ADMIN | Notification được gửi |

---

## 4.2 Use Case chi tiết

---

### UC02 – Đăng nhập

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Đăng nhập |
| **Tác nhân** | CUSTOMER, STAFF, ADMIN |
| **Mục tiêu** | Xác thực danh tính và nhận JWT để truy cập hệ thống |
| **API liên quan** | `POST /api/v1/auth/sign-in` |
| **File code** | `auth.controller.js`, `user-auth.service.js` |

**Luồng chính:**
1. User nhập email và password
2. Hệ thống kiểm tra email tồn tại trong DB
3. Hệ thống so sánh password với bcrypt hash
4. Hệ thống tạo Access Token (JWT, thời gian ngắn) và Refresh Token (thời gian dài)
5. Trả về `{ accessToken, refreshToken, user: { id, email, role, profile } }`
6. Client lưu token vào SecureStorage (Flutter) / LocalStorage (Web)
7. Flutter đăng ký FCM Token lên server

**Luồng thay thế:**
- Email không tồn tại → 401 UNAUTHORIZED
- Mật khẩu sai → 401 UNAUTHORIZED
- Tài khoản INACTIVE/BANNED → 403 FORBIDDEN

**Ngoại lệ:**
- User có status `PENDING_OTP` → chưa xác thực → thông báo lỗi

---

### UC09 – Đặt sân

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Đặt sân |
| **Tác nhân** | CUSTOMER (chủ yếu), STAFF/ADMIN (thay khách) |
| **Mục tiêu** | Tạo booking sân theo slot giờ |
| **API liên quan** | `POST /api/v1/booking` |
| **File code** | `booking.controller.js`, `booking.service.js`, `court-availability.service.js`, `booking-price.service.js` |

**Luồng chính:**
1. User chọn Facility → chọn Sport → chọn Court
2. App hiển thị slot giờ từ `slot_config` của Court
3. User chọn ngày, slot giờ
4. App gọi API kiểm tra khả dụng
5. Backend kiểm tra: Court ACTIVE, không có CourtBlock, không trùng booking khác, slot hợp lệ
6. Backend tính total_price = `price_per_hour × duration`
7. Tạo Booking với status `PENDING`
8. Tạo Payment với status `PENDING`
9. Gửi thông báo đến STAFF của cơ sở
10. Trả về booking vừa tạo

**Luồng thay thế:**
- Slot đã bị đặt → 409 CONFLICT
- Court đang MAINTENANCE → lỗi xác thực
- CourtBlock tồn tại trong khung giờ → 409

**Ngoại lệ:**
- User có booking PENDING khác cùng giờ → kiểm tra conflict

---

### UC10 – Hủy booking

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Hủy booking |
| **Tác nhân** | CUSTOMER, STAFF, ADMIN |
| **Mục tiêu** | Hủy một booking đã tạo |
| **API liên quan** | `PUT /api/v1/booking/:id/cancel` |
| **File code** | `booking.controller.js`, `booking.service.js`, `notification.helper.js` |

**Luồng chính:**
1. User gửi request hủy booking với lý do (tùy chọn)
2. Backend kiểm tra quyền: CUSTOMER chỉ hủy booking của chính mình
3. Backend kiểm tra trạng thái: booking phải PENDING hoặc CONFIRMED
4. Cập nhật booking: `status → CANCELLED`, ghi `cancel_reason`, `cancelled_by`, `cancelled_at`
5. Cập nhật payment liên quan nếu có
6. Gửi thông báo đến user và STAFF
7. Trả về booking đã hủy

**Luồng thay thế:**
- Booking đã COMPLETED → không thể hủy
- Booking đã CANCELLED → không thể hủy lại

---

### UC13 – Thanh toán ZaloPay

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Thanh toán ZaloPay |
| **Tác nhân** | CUSTOMER |
| **Mục tiêu** | Thanh toán hóa đơn qua ZaloPay |
| **API liên quan** | `POST /api/v1/zalopay/create-order`, `POST /api/v1/zalopay/query`, `POST /api/v1/zalopay/callback` |
| **File code** | `zalopay.controller.js`, `zalopay.service.js`, `payment.service.js` |

**Luồng chính:**
1. User chọn thanh toán ZaloPay cho payment PENDING
2. App gọi `POST /api/v1/zalopay/create-order` với `{ paymentId }`
3. Backend tạo đơn hàng ZaloPay với HMAC signature
4. Trả về `{ order_url, app_trans_id }`
5. App mở URL ZaloPay để user thanh toán
6. ZaloPay gọi callback về `POST /api/v1/zalopay/callback`
7. Backend xác thực HMAC, cập nhật payment → SUCCESS
8. Backend cập nhật booking → CONFIRMED
9. Backend gửi thông báo thành công đến user
10. App polling `POST /api/v1/zalopay/query` để cập nhật UI

---

### UC18 – Tạo phiên ghép trận

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Tạo phiên ghép trận |
| **Tác nhân** | CUSTOMER (Host) |
| **Mục tiêu** | Tạo MatchingSession để tìm người chơi cùng |
| **API liên quan** | `POST /api/v1/matching` |
| **File code** | `matching.controller.js`, `matching.service.js`, `notification.helper.js` |

**Luồng chính:**
1. Host chọn booking đã có (hoặc tạo mới booking + session)
2. Chọn chế độ: INDIVIDUAL / TEAM_FILL / TEAM_VS_TEAM
3. Nhập số người cần tuyển, mô tả, chính sách thanh toán
4. Backend kiểm tra: host chưa có session OPEN/FULL cùng khung giờ
5. Tạo MatchingSession với status `OPEN`
6. Host tự động là member đầu tiên với team_code `A`
7. Gửi thông báo broadcast cho users quan tâm
8. Trả về session vừa tạo

**Luồng thay thế:**
- Host đã có session active cùng giờ → 409 (unique index)
- Booking không tồn tại → 404

---

### UC15 – Duyệt lịch cố định

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Duyệt lịch cố định |
| **Tác nhân** | ADMIN, STAFF |
| **Mục tiêu** | Phê duyệt đăng ký lịch đặt sân định kỳ của CUSTOMER |
| **API liên quan** | `PUT /api/v1/fixed-schedule/:id/approve` |
| **File code** | `fixed-schedule.controller.js`, `fixed-schedule.service.js` |

**Luồng chính:**
1. STAFF/ADMIN xem danh sách lịch PENDING_APPROVAL
2. Kiểm tra thông tin: court, thời gian, ngày bắt đầu
3. Gọi API approve
4. Backend kiểm tra quyền, trạng thái lịch
5. Cập nhật status → `ACTIVE`, ghi `approved_by`, `approved_at`
6. Ngay lập tức sinh booking cho range hiện tại (7 ngày tới)
7. Gửi thông báo thành công đến CUSTOMER
8. Trả về fixed schedule đã duyệt

**Luồng thay thế:**
- Reject: `PUT /api/v1/fixed-schedule/:id/reject` → status REJECTED, gửi thông báo từ chối

---

### UC24 – Xem báo cáo nâng cao (ADMIN)

| Thuộc tính | Nội dung |
|------------|----------|
| **Tên** | Xem báo cáo nâng cao |
| **Tác nhân** | ADMIN |
| **Mục tiêu** | Xem dashboard tổng quan về doanh thu, booking, matching |
| **API liên quan** | `GET /api/v1/reports/advanced-performance` |
| **File code** | `reports.controller.js`, `report.service.js` |

**Luồng chính:**
1. ADMIN truy cập `/admin/overview`
2. Chọn khoảng thời gian, cơ sở (tùy chọn)
3. Gọi API với query params
4. Backend tổng hợp: tổng booking, doanh thu, court utilization, matching stats
5. Hiển thị biểu đồ (Recharts) và bảng số liệu

---

## 4.3 Activity Diagram cần vẽ

### Activity 1: Quy trình đặt sân

**Swimlane:** CUSTOMER | Mobile App | Backend API | Database

**Các bước:**
1. [CUSTOMER] Mở app, chọn "Đặt sân"
2. [App] Hiển thị danh sách Facility
3. [CUSTOMER] Chọn cơ sở
4. [App] Hiển thị danh sách sân theo cơ sở + môn thể thao
5. [CUSTOMER] Chọn sân, chọn ngày
6. [App] Hiển thị slot giờ từ slot_config
7. [CUSTOMER] Chọn slot giờ
8. [App] Hiển thị giá và xác nhận
9. [CUSTOMER] Xác nhận đặt sân
10. [Backend] Kiểm tra xung đột: có trùng booking không?
    - Có trùng → [App] Thông báo lỗi → Kết thúc (hủy bỏ)
    - Không trùng → Tiếp tục
11. [Backend] Kiểm tra CourtBlock trong khung giờ
    - Có block → Thông báo lỗi → Kết thúc
    - Không có → Tiếp tục
12. [Backend] Tính giá, tạo Booking (PENDING), tạo Payment (PENDING)
13. [Database] Lưu Booking + Payment
14. [Backend] Gửi thông báo cho STAFF
15. [App] Hiển thị màn hình booking thành công

**Điều kiện rẽ nhánh:**
- Court ACTIVE vs INACTIVE/MAINTENANCE
- Slot trùng lịch vs còn trống
- CourtBlock tồn tại vs không có

---

### Activity 2: Duyệt / Hủy booking (STAFF)

**Swimlane:** STAFF | Web Admin | Backend API | Database | Notification

**Các bước:**
1. [STAFF] Đăng nhập Web Admin
2. [STAFF] Vào trang "Quản lý Booking"
3. [Web] Hiển thị danh sách booking PENDING
4. [STAFF] Chọn booking để xem chi tiết
5. [STAFF] Quyết định: Duyệt hay Từ chối?
   - **Duyệt:**
     1. [STAFF] Click "Xác nhận"
     2. [Backend] Cập nhật status → CONFIRMED
     3. [Backend] Gửi notification đến CUSTOMER
     4. [Web] Cập nhật UI
   - **Hủy:**
     1. [STAFF] Nhập lý do hủy
     2. [Backend] Cập nhật status → CANCELLED
     3. [Backend] Cập nhật Payment liên quan
     4. [Backend] Gửi notification đến CUSTOMER
     5. [Web] Cập nhật UI

---

### Activity 3: Quy trình thanh toán

**Swimlane:** CUSTOMER | App | Backend | ZaloPay | Database

**Các bước:**
1. [CUSTOMER] Xem danh sách hóa đơn
2. [CUSTOMER] Chọn hóa đơn PENDING
3. [CUSTOMER] Chọn phương thức: ZaloPay / Tiền mặt
4. **ZaloPay:**
   1. [App] Gọi `POST /zalopay/create-order`
   2. [Backend] Tạo order ZaloPay với HMAC
   3. [App] Mở WebView/App ZaloPay
   4. [CUSTOMER] Thanh toán trên ZaloPay
   5. [ZaloPay] Gọi callback về Backend
   6. [Backend] Xác thực HMAC, cập nhật Payment SUCCESS
   7. [App] Polling để cập nhật UI
5. **Tiền mặt:**
   1. [STAFF] Vào StaffCashierPage
   2. [STAFF] Tìm hóa đơn theo booking_id
   3. [STAFF] Xác nhận thu tiền
   4. [Backend] Cập nhật Payment SUCCESS, method CASH
   5. [Web] Hiển thị xác nhận

---

### Activity 4: Ghép trận tự động

**Swimlane:** CUSTOMER | App | Backend (Cron) | Database | Notification

**Các bước:**
1. [CUSTOMER] Mở màn hình AutoMatchingLobby
2. [CUSTOMER] Nhập thông tin: sport, facility, ngày, giờ, số người
3. [App] Gọi `POST /matching/queue/join`
4. [Backend] Tạo MatchQueue entry (SEARCHING)
5. [App] Polling `GET /matching/queue/status`
6. **Cron job (mỗi 1 phút):**
   1. Quét tất cả MatchQueue SEARCHING
   2. Nhóm theo (sport, facility, date, time, group_size, team_mode)
   3. Nếu đủ người → Tạo MatchingSession, gán thành viên
   4. Cập nhật queue → MATCHED
   5. Gửi notification đến tất cả thành viên
7. [App] Nhận kết quả MATCHED → Chuyển màn hình MatchingDetail

**Điều kiện rẽ nhánh:**
- Đủ người → Ghép thành công
- Không đủ người → Tiếp tục chờ
- Hết thời gian chờ → EXPIRED

---

### Activity 5: Lịch cố định

**Swimlane:** CUSTOMER | App | Backend | Cron | Database

**Các bước:**
1. [CUSTOMER] Tạo đăng ký lịch cố định (loại, sân, ngày, giờ, tần suất)
2. [Backend] Tạo FixedSchedule (PENDING_APPROVAL)
3. [Backend] Gửi thông báo cho STAFF/ADMIN
4. [STAFF/ADMIN] Xét duyệt trên Web Admin
   - Duyệt → ACTIVE → Backend sinh booking cho 7 ngày tới
   - Từ chối → REJECTED → Thông báo cho CUSTOMER
5. **Cron job (00:05 hàng ngày):**
   1. Quét tất cả FixedSchedule ACTIVE
   2. Với mỗi lịch, sinh booking cho ngày tiếp theo (chưa có booking)
   3. Bỏ qua exception_dates
   4. Lưu booking mới vào DB
6. [CUSTOMER] Có thể tạm dừng, tiếp tục, hủy một buổi, hủy cả chuỗi

---

### Activity 6: Báo cáo thống kê

**Swimlane:** ADMIN/STAFF | Web Admin | Backend | Database

**Các bước:**
1. [ADMIN/STAFF] Truy cập trang báo cáo
2. [Web] Hiển thị form lọc: facility, date range, sport
3. [ADMIN/STAFF] Chọn bộ lọc, submit
4. [Backend] Query MongoDB, tổng hợp dữ liệu
5. **Cho STAFF:** court-performance → booking count, revenue per court, occupancy rate
6. **Cho ADMIN:** advanced-performance → tổng doanh thu, booking trend, matching stats, fixed schedule stats
7. [Web] Hiển thị biểu đồ Recharts + bảng số liệu

---

## 4.4 Sequence Diagram cần vẽ

### Sequence 1: Đăng nhập

| Thứ tự | Từ | Đến | Message |
|--------|-----|-----|---------|
| 1 | Actor (User) | Mobile/Web | Nhập email, password → Submit |
| 2 | Mobile/Web | Backend API (`auth.controller.signIn`) | `POST /api/v1/auth/sign-in` {email, password} |
| 3 | Backend | `user-auth.service` | `signIn(email, password)` |
| 4 | `user-auth.service` | MongoDB (User collection) | `findOne({ email })` |
| 5 | MongoDB | `user-auth.service` | User document |
| 6 | `user-auth.service` | bcrypt | `compare(password, user.password)` |
| 7 | bcrypt | `user-auth.service` | boolean |
| 8 | `user-auth.service` | JWT | `sign({ id, email, role }, JWT_SECRET)` |
| 9 | JWT | `user-auth.service` | accessToken, refreshToken |
| 10 | `user-auth.service` | Backend | `{ accessToken, refreshToken, user }` |
| 11 | Backend | Mobile/Web | HTTP 200 `{ success, data }` |
| 12 | Mobile | SecureStorage | Lưu token |
| 13 | Mobile | Backend API | `POST /api/v1/user/register-fcm` {fcmToken} |
| 14 | Backend | MongoDB (User) | Update fcmTokens |

---

### Sequence 2: Đặt sân

| Thứ tự | Từ | Đến | Message |
|--------|-----|-----|---------|
| 1 | CUSTOMER | Flutter App | Chọn sân, ngày, slot |
| 2 | Flutter | Backend (`booking.controller.createBooking`) | `POST /api/v1/booking` {court_id, booking_date, start_minutes, end_minutes} |
| 3 | Backend | `booking.service` | `createBooking(data)` |
| 4 | `booking.service` | MongoDB (Court) | `findById(court_id)` – kiểm tra ACTIVE |
| 5 | `booking.service` | MongoDB (CourtBlock) | Kiểm tra block trong khung giờ |
| 6 | `booking.service` | `court-availability.service` | `checkAvailability(...)` |
| 7 | `court-availability.service` | MongoDB (Booking) | Query booking trùng lịch |
| 8 | MongoDB | `court-availability.service` | Danh sách booking trùng |
| 9 | `court-availability.service` | `booking.service` | Available: true/false |
| 10 | `booking.service` | `booking-price.service` | `calculatePrice(court, duration)` |
| 11 | `booking.service` | MongoDB (Booking) | `create(booking)` |
| 12 | `booking.service` | MongoDB (Payment) | `create(payment)` |
| 13 | `booking.service` | `notification.helper` | `notifyStaffNewBooking(...)` |
| 14 | `notification.helper` | `socket-io.service` | `notifyStaff(notification)` |
| 15 | `socket-io.service` | Web Admin (STAFF) | Socket event `new_notification` |
| 16 | Backend | Flutter | HTTP 201 `{ booking, payment }` |

---

### Sequence 3: Tạo ghép trận + Socket.IO

| Thứ tự | Từ | Đến | Message |
|--------|-----|-----|---------|
| 1 | CUSTOMER | Flutter | Điền form tạo session |
| 2 | Flutter | Backend (`matching.controller.createSession`) | `POST /api/v1/matching` {sport_id, facility_id, court_id, booking_date, ...} |
| 3 | Backend | `matching.service` | `createSession(data)` |
| 4 | `matching.service` | MongoDB (MatchingSession) | Tạo session mới |
| 5 | `matching.service` | `notification.helper` | `notifyMatchingCreated(session)` |
| 6 | `notification.helper` | MongoDB (Notification) | Tạo notification records |
| 7 | `notification.helper` | `socket-io.service` | `broadcastToUsers(userIds, notification)` |
| 8 | `socket-io.service` | Online Users | Socket `notification_received` |
| 9 | `notification.helper` | `fcm.service` | `sendPushNotification(tokens, payload)` |
| 10 | `fcm.service` | Firebase FCM | Firebase Admin SDK push |
| 11 | Firebase FCM | Offline Devices | Push notification |
| 12 | Backend | Flutter | HTTP 201 `{ session }` |
| 13 | CUSTOMER 2 | Flutter | Join session `POST /api/v1/matching/:id/join` |
| 14 | Backend | `socket-io.service` | `notifyMatchingUpdate(sessionId, data)` |
| 15 | `socket-io.service` | All in `room_matching_{id}` | `matching_session_updated` |

---

### Sequence 4: Gửi thông báo FCM

| Thứ tự | Từ | Đến | Message |
|--------|-----|-----|---------|
| 1 | `booking.service` | `notification.helper` | `createAndSendNotification(userId, data)` |
| 2 | `notification.helper` | MongoDB (Notification) | `create(notification)` |
| 3 | `notification.helper` | MongoDB (User) | `findById(userId)` – lấy fcmTokens |
| 4 | `notification.helper` | `socket-io.service` | `notifyUser(userId, notification)` |
| 5 | `socket-io.service` | Flutter App (online) | Socket event `new_notification` |
| 6 | `notification.helper` | `fcm.service` | `sendToDevices(fcmTokens, payload)` |
| 7 | `fcm.service` | Firebase Admin SDK | `messaging.sendEachForMulticast(message)` |
| 8 | Firebase | Flutter App (offline) | Push notification |
| 9 | Flutter | `flutter_local_notifications` | Hiển thị notification bar |
