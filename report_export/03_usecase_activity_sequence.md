# 4. THIẾT KẾ HỆ THỐNG — USE CASE, ACTIVITY, SEQUENCE

## 4.1 Use Case tổng quát

| Mã UC | Tên Use Case | Tác nhân | Mô tả | Điều kiện trước | Kết quả sau |
|-------|-------------|----------|-------|----------------|-------------|
| UC01 | Đăng ký tài khoản | CUSTOMER | Tạo tài khoản mới bằng email | Chưa có tài khoản | Tài khoản tạo, chờ xác thực OTP |
| UC02 | Xác thực email | CUSTOMER | Nhập OTP để kích hoạt | Đã đăng ký, có OTP | Tài khoản ACTIVE |
| UC03 | Đăng nhập | CUSTOMER, STAFF, ADMIN | Xác thực thông tin, nhận JWT | Tài khoản ACTIVE | Có Access/Refresh Token |
| UC04 | Đặt sân | CUSTOMER | Chọn sân, slot, tạo booking | Đã đăng nhập, sân ACTIVE | Booking PENDING |
| UC05 | Duyệt booking | STAFF, ADMIN | Xác nhận booking của khách | Booking PENDING | Booking CONFIRMED |
| UC06 | Hủy booking | CUSTOMER, STAFF, ADMIN | Hủy booking với lý do | Booking PENDING/CONFIRMED | Booking CANCELLED |
| UC07 | Thanh toán hóa đơn | CUSTOMER | Tạo payment, chọn phương thức | Booking CONFIRMED | Payment SUCCESS/PENDING |
| UC08 | Thu tiền mặt | STAFF | Xác nhận thu tiền tại quầy | Payment PENDING (CASH) | Payment SUCCESS |
| UC09 | Tạo lịch cố định | CUSTOMER | Đặt sân định kỳ DAILY/WEEKLY | Đã đăng nhập | FixedSchedule PENDING_APPROVAL |
| UC10 | Duyệt lịch cố định | STAFF, ADMIN | Phê duyệt/từ chối | FixedSchedule PENDING_APPROVAL | ACTIVE hoặc REJECTED |
| UC11 | Hủy một buổi lịch cố định | CUSTOMER | Bỏ qua một ngày cụ thể | FixedSchedule ACTIVE | exception_date thêm vào |
| UC12 | Tạm dừng lịch cố định | STAFF, ADMIN | Dừng sinh booking tạm thời | FixedSchedule ACTIVE | FixedSchedule PAUSED |
| UC13 | Tạo phòng ghép trận | CUSTOMER | Tạo MatchingSession thủ công | Đã đăng nhập, có booking | Session OPEN |
| UC14 | Tham gia phòng ghép trận | CUSTOMER | Join MatchingSession | Session OPEN, chưa FULL | Member thêm vào |
| UC15 | Rời phòng ghép trận | CUSTOMER | Leave MatchingSession | Đang là member | Member bị xóa |
| UC16 | Ghép trận tự động | CUSTOMER | Vào hàng đợi tìm đối thủ | Đã đăng nhập | MatchQueue SEARCHING → MATCHED |
| UC17 | Duyệt thành viên | CUSTOMER (host) | Approve/reject member request | auto_approve = false | Member APPROVED/REJECTED |
| UC18 | Xem lịch sử booking | CUSTOMER | Xem booking của mình | Đã đăng nhập | Danh sách booking |
| UC19 | Đánh giá sân | CUSTOMER | Gửi rating + comment | Booking COMPLETED | Review tạo |
| UC20 | Xem báo cáo doanh thu | ADMIN | Xem thống kê revenue | Đã đăng nhập ADMIN | Dữ liệu biểu đồ |
| UC21 | Xem báo cáo hiệu suất sân | STAFF, ADMIN | Xem utilization rate | Đã đăng nhập | Thống kê theo sân |
| UC22 | Quản lý người dùng | ADMIN | Xem/sửa role/status user | Đã đăng nhập ADMIN | User được cập nhật |
| UC23 | Quản lý cơ sở/sân/môn | ADMIN | CRUD facility/court/sport | Đã đăng nhập ADMIN | Dữ liệu cập nhật |
| UC24 | Cấu hình slot sân | STAFF | Thiết lập giờ mở/đóng, slot duration | Đã đăng nhập STAFF | Slot config cập nhật |
| UC25 | Block sân/bảo trì | STAFF, ADMIN | Tạo court block | Đã đăng nhập | CourtBlock ACTIVE |
| UC26 | Nhận thông báo realtime | CUSTOMER, STAFF, ADMIN | Nhận sự kiện qua Socket.IO | Đang kết nối socket | Notification hiển thị ngay |
| UC27 | Cập nhật hồ sơ | Tất cả | Sửa tên, SĐT, avatar | Đã đăng nhập | Profile cập nhật |
| UC28 | Đổi mật khẩu | Tất cả | Nhập mật khẩu cũ + mới | Đã đăng nhập | Mật khẩu cập nhật |
| UC29 | Quên mật khẩu | CUSTOMER | Gửi OTP qua email | Không đăng nhập | OTP gửi email |
| UC30 | Quản lý matching (xem) | STAFF, ADMIN | Theo dõi matching sessions | Đã đăng nhập | Danh sách session |

---

## 4.2 Use Case Chi tiết

---

### UC03 — Đăng nhập

**Tác nhân**: CUSTOMER, STAFF, ADMIN  
**Mục tiêu**: Xác thực người dùng và cấp JWT tokens để truy cập hệ thống  
**File code liên quan**:
- Controller: `src/controllers/auth.controller.js` — `signIn()`
- Service: `src/services/user-auth.service.js` — `signIn()`
- Route: `src/routes/auth.routes.js` — `POST /sign-in`
- Flutter: `modules/authentication_module/lib/presentation/pages/sign_in_page.dart`
- React: `src/features/auth/presentation/pages/login_page.tsx`

**Luồng chính**:
1. Người dùng nhập email + mật khẩu (hoặc Firebase Token)
2. POST `/api/v1/auth/sign-in` với `{ email, password }`
3. Service tra cứu User theo email trong MongoDB
4. bcrypt so sánh mật khẩu hash
5. Kiểm tra status ACTIVE
6. Tạo Access Token (JWT) + Refresh Token
7. Trả về `{ accessToken, refreshToken, user: { id, email, role, profile } }`

**Luồng thay thế**:
- Đăng nhập Firebase: `POST /api/v1/auth/firebase/login` với Firebase ID Token → verify qua Firebase Admin SDK → tạo JWT nội bộ

**Ngoại lệ/lỗi**:
- Email không tồn tại → 401 `INVALID_CREDENTIALS`
- Mật khẩu sai → 401 `INVALID_CREDENTIALS`
- Tài khoản BANNED → 403 `ACCOUNT_BANNED`
- Tài khoản PENDING_OTP/PENDING_EMAIL → 403 `EMAIL_NOT_VERIFIED`

**API liên quan**: `POST /api/v1/auth/sign-in`

---

### UC04 — Đặt sân

**Tác nhân**: CUSTOMER (mobile), STAFF (tạo cho walk-in guest)  
**Mục tiêu**: Tạo booking mới cho sân trong khoảng thời gian cụ thể  
**File code liên quan**:
- Controller: `src/controllers/booking.controller.js` — `createBooking()`
- Service: `src/services/booking.service.js` — `createBooking()`
- Service: `src/services/court-availability.service.js` — `checkCourtAvailability()`
- Service: `src/services/booking-price.service.js` — `calculatePrice()`
- Flutter: `modules/booking_module/lib/presentation/pages/court_booking_page.dart`

**Luồng chính**:
1. Customer chọn facility → sport → court
2. Chọn ngày và slot thời gian (start_minutes, end_minutes)
3. Flutter gọi GET `/api/v1/court/:id/slot-config` để lấy slot config
4. Flutter hiển thị calendar + available slots
5. Customer chọn slot, nhấn "Đặt sân"
6. POST `/api/v1/booking` với `{ court_id, booking_date, start_minutes, end_minutes }`
7. Service kiểm tra sân ACTIVE
8. Service kiểm tra trùng lịch (booking conflict, court block, fixed schedule conflict)
9. Service tính giá: `price_per_hour × duration_hours`
10. Tạo Booking với status PENDING
11. Tạo Payment PENDING
12. Gửi thông báo đến STAFF (Socket.IO `room_staff` + FCM)
13. Trả về booking + payment info

**Điều kiện kiểm tra conflict**:
- Không có booking PENDING/CONFIRMED/COMPLETED trùng `court_id + booking_date + [start, end]`
- Không có CourtBlock ACTIVE bao phủ thời gian
- Không trùng với fixed schedule booking đã được gen

**Luồng thay thế**:
- Tạo lịch cố định: bật toggle "Lịch cố định" → chọn frequency DAILY/WEEKLY, days_of_week → tạo FixedSchedule thay vì Booking

**Ngoại lệ/lỗi**:
- Sân không tồn tại hoặc INACTIVE → 404/400
- Trùng lịch → 409 `SLOT_CONFLICT`
- Ngày trong quá khứ → 400

---

### UC05 — Duyệt booking

**Tác nhân**: STAFF, ADMIN  
**Mục tiêu**: Xác nhận booking của khách, chuyển sang CONFIRMED  
**File code liên quan**:
- Controller: `src/controllers/booking.controller.js` — `updateBookingStatus()`
- Service: `src/services/booking.service.js` — `updateBookingStatus()`
- Route: `PUT /api/v1/booking/:id/status`
- React: `src/features/booking/presentation/pages/staff_bookings_page.tsx`
- Flutter: `modules/home_module/lib/presentation/pages/staff_dashboard_section.dart`

**Luồng chính**:
1. STAFF mở danh sách booking PENDING
2. Chọn booking → xem chi tiết
3. Nhấn "Xác nhận" (CONFIRMED)
4. PUT `/api/v1/booking/:id/status` với `{ status: 'CONFIRMED' }`
5. Service cập nhật booking status
6. Gửi thông báo cho CUSTOMER (Socket.IO `user_${userId}` + FCM)
7. Trả về booking đã cập nhật

**Ngoại lệ/lỗi**:
- Booking không tồn tại → 404
- Không phải PENDING → 400 `INVALID_STATUS_TRANSITION`
- STAFF không thuộc facility → 403

---

### UC06 — Hủy booking

**Tác nhân**: CUSTOMER (own), STAFF, ADMIN  
**Mục tiêu**: Hủy booking với lý do cụ thể  
**File code liên quan**:
- Controller: `src/controllers/booking.controller.js` — `cancelBooking()`
- Service: `src/services/booking.service.js` — `cancelBooking()`
- Route: `PUT /api/v1/booking/:id/cancel`
- Flutter: `modules/booking_module/lib/presentation/pages/booking_detail_page.dart`
- React: `src/features/booking/presentation/pages/booking_detail_page.tsx`

**Luồng chính**:
1. User chọn booking muốn hủy
2. Nhập lý do hủy
3. PUT `/api/v1/booking/:id/cancel` với `{ cancel_reason, cancelled_by }`
4. Service kiểm tra quyền (CUSTOMER chỉ hủy booking của mình)
5. Kiểm tra trạng thái: chỉ PENDING/CONFIRMED mới được hủy
6. Cập nhật: `status: CANCELLED`, `cancel_reason`, `cancelled_by`, `cancelled_at`
7. Cập nhật Payment liên quan → CANCELLED
8. Gửi thông báo cho user + STAFF/ADMIN
9. Trả về booking đã hủy

**Ngoại lệ**:
- Booking đã COMPLETED → không thể hủy
- Booking đã CANCELLED → không thể hủy lại
- CUSTOMER hủy booking của người khác → 403

---

### UC07 — Thanh toán/Cập nhật hóa đơn

**Tác nhân**: CUSTOMER (ZaloPay), STAFF (CASH)  
**Mục tiêu**: Hoàn thành thanh toán cho booking  
**File code liên quan**:
- Controller: `src/controllers/payment.controller.js`, `src/controllers/zalopay.controller.js`
- Service: `src/services/payment.service.js`, `src/services/zalopay.service.js`
- Flutter: `modules/payment_module/lib/presentation/pages/invoice_detail_page.dart`
- Flutter: `modules/payment_module/lib/presentation/pages/zalopay_webview_page.dart`
- React: `src/features/payment/presentation/pages/staff_cashier_page.tsx`

**Luồng ZaloPay (CUSTOMER)**:
1. Customer vào trang invoice, chọn "ZaloPay"
2. POST `/api/v1/zalopay/create-order` với `{ paymentId }`
3. Backend tạo ZaloPay order, trả về `order_url`, `deeplink_url`, `qr_code`
4. Flutter mở `zalopay_webview_page.dart` với `order_url`
5. Customer thanh toán trên ZaloPay
6. ZaloPay gọi callback `POST /api/v1/zalopay/callback`
7. Backend verify HMAC, cập nhật Payment → SUCCESS, Booking → CONFIRMED
8. Socket.IO thông báo cho customer và staff

**Luồng CASH (STAFF)**:
1. STAFF mở `staff_cashier_page.tsx`
2. Tìm booking/payment của khách
3. Nhấn "Đã thu tiền" → PUT `/api/v1/payment/:id/status` với `{ status: 'SUCCESS' }`
4. Payment cập nhật, Booking cập nhật

---

### UC09 — Tạo lịch cố định

**Tác nhân**: CUSTOMER  
**Mục tiêu**: Đặt sân định kỳ theo ngày/tuần  
**File code liên quan**:
- Controller: `src/controllers/fixed-schedule.controller.js` — `createFixedSchedule()`
- Service: `src/services/fixed-schedule.service.js`
- Route: `POST /api/v1/fixed-schedule`
- Flutter: `modules/booking_module/lib/presentation/pages/court_booking_page.dart`

**Luồng chính**:
1. Customer bật chế độ "Lịch cố định" khi đặt sân
2. Chọn: frequency (DAILY/WEEKLY), days_of_week (nếu WEEKLY), start_date, end_date (optional)
3. POST `/api/v1/fixed-schedule` với đầy đủ thông tin
4. Service kiểm tra conflict: có booking/fixed schedule nào trùng không
5. Tạo FixedSchedule với `status: PENDING_APPROVAL`
6. Gửi thông báo cho STAFF để duyệt
7. Cron `fixedScheduler` sẽ sinh booking khi được APPROVE

---

### UC10 — Duyệt lịch cố định

**Tác nhân**: STAFF, ADMIN  
**Mục tiêu**: Phê duyệt lịch cố định, kích hoạt sinh booking tự động  
**File code liên quan**:
- Controller: `src/controllers/fixed-schedule.controller.js` — `approveFixedSchedule()`
- Service: `src/services/fixed-schedule.service.js` — `approveFixedSchedule()`
- Route: `PUT /api/v1/fixed-schedule/:id/approve`
- React: `src/features/fixed_schedule/presentation/pages/fixed_schedule_detail_page.tsx`

**Luồng chính**:
1. STAFF mở danh sách fixed schedule PENDING_APPROVAL
2. Xem chi tiết: ngày, giờ, sân, frequency
3. Nhấn "Duyệt" → PUT `/api/v1/fixed-schedule/:id/approve`
4. Service cập nhật `status: ACTIVE`, lưu `approved_by`, `approved_at`
5. Service gọi `generateBookingsForRange()` để sinh booking ngay lập tức cho 7-14 ngày tới
6. Gửi thông báo cho CUSTOMER
7. Cron `fixedScheduler` (00:05 hàng ngày) tiếp tục sinh booking kéo dài theo range

**Luồng từ chối**:
1. Nhấn "Từ chối" + nhập lý do
2. PUT `/api/v1/fixed-schedule/:id/reject` với `{ rejection_reason }`
3. `status: REJECTED`, lưu `rejected_by`, `rejected_reason`

---

### UC13 — Tạo phòng ghép trận

**Tác nhân**: CUSTOMER  
**Mục tiêu**: Tạo MatchingSession để tìm đối thủ  
**File code liên quan**:
- Controller: `src/controllers/matching.controller.js` — `createSession()`
- Service: `src/services/matching.service.js`
- Route: `POST /api/v1/matching`
- Flutter: `modules/matching_module/lib/presentation/pages/create_matching_session_page.dart`

**Luồng chính**:
1. Customer có booking đã CONFIRMED
2. Mở `create_matching_session_page.dart`
3. Chọn: facility, court, booking_date, start/end_minutes
4. Chọn team_mode: INDIVIDUAL/TEAM_FILL/TEAM_VS_TEAM
5. Chọn total_players_needed, payment_policy, auto_approve
6. POST `/api/v1/matching` với `{ booking_id, sport_id, facility_id, court_id, ... }`
7. Service kiểm tra booking thuộc về host
8. Tạo MatchingSession `status: OPEN`
9. Host tự động được thêm vào members với `status: APPROVED`
10. Trả về session

---

### UC14 — Tham gia phòng ghép trận

**Tác nhân**: CUSTOMER  
**Mục tiêu**: Join vào MatchingSession đang mở  
**File code liên quan**:
- Controller: `src/controllers/matching.controller.js` — `joinSession()`
- Service: `src/services/matching.service.js`
- Route: `POST /api/v1/matching/:id/join`
- Flutter: `modules/matching_module/lib/presentation/pages/matching_detail_page.dart`

**Luồng chính**:
1. Customer tìm session trên `matching_explorer_page.dart`
2. Mở `matching_detail_page.dart`
3. Nhấn "Tham gia"
4. POST `/api/v1/matching/:id/join` với `{ join_mode, team_code, represented_count, note }`
5. Service kiểm tra: session OPEN, chưa FULL, user chưa là member
6. Nếu `auto_approve = true` → member status APPROVED ngay
7. Nếu `auto_approve = false` → member status PENDING, thông báo host
8. Kiểm tra nếu đủ player → session FULL
9. Socket.IO emit `matching_session_updated` cho tất cả trong `room_matching_{id}`

---

### UC16 — Ghép trận tự động

**Tác nhân**: CUSTOMER  
**Mục tiêu**: Tự động tìm và ghép đối thủ qua hàng đợi  
**File code liên quan**:
- Controller: `src/controllers/matching.controller.js` — `joinQueue()`, `leaveQueue()`, `getQueueStatus()`
- Service: `src/services/matching.service.js` — `runMatchmakerAlgorithm()`
- Cron: `src/utils/cron-matchmaker.js`
- Flutter: `modules/matching_module/lib/presentation/pages/auto_matching_lobby_page.dart`

**Luồng chính**:
1. Customer mở `auto_matching_lobby_page.dart`
2. Chọn: facility, sport, booking_date, start/end_minutes, group_size, team_mode, payment_policy
3. POST `/api/v1/matching/queue/join`
4. MatchQueue entry tạo với `status: SEARCHING`
5. Cron `matchmaker` chạy mỗi phút:
   - Lấy tất cả SEARCHING queue theo sport + facility + date
   - Nhóm các entry tương thích (thời gian trùng, team_mode khớp)
   - Nếu đủ player → gọi `createAutoMatchSession()` → tạo booking tự động + MatchingSession
   - Cập nhật queue entries → `status: MATCHED`
   - Thông báo tất cả players
6. Customer polling qua GET `/api/v1/matching/queue/status`
7. Khi MATCHED → navigate đến session

---

### UC11 — Hủy một buổi lịch cố định

**Tác nhân**: CUSTOMER  
**Mục tiêu**: Bỏ qua một ngày cụ thể trong chuỗi lịch cố định  
**File code liên quan**:
- Controller: `src/controllers/fixed-schedule.controller.js` — `cancelFixedMatchingOccurrence()`
- Service: `src/services/fixed-schedule.service.js`
- Route: `POST /api/v1/fixed-schedule/:id/occurrences/:date/cancel`
- Flutter: `modules/booking_module/lib/presentation/pages/booking_detail_page.dart`

**Luồng chính**:
1. Customer chọn booking trong ngày muốn hủy (thuộc fixed schedule)
2. POST `/api/v1/fixed-schedule/:id/occurrences/2024-12-25/cancel` với `{ reason }`
3. Service thêm `exception_dates: [{ date, type: 'CANCELLED', reason }]`
4. Các booking đã gen cho ngày đó được hủy
5. Cron sẽ bỏ qua ngày exception khi sinh booking tương lai

---

### UC20 — Xem báo cáo

**Tác nhân**: ADMIN, STAFF  
**Mục tiêu**: Xem thống kê hiệu suất và doanh thu  
**File code liên quan**:
- Controller: `src/controllers/reports.controller.js`
- Service: `src/services/report.service.js` (41KB)
- Route: `GET /api/v1/reports/advanced-performance`, `GET /api/v1/reports/court-performance`
- React (Admin): `src/features/report/presentation/pages/admin_overview_page.tsx`
- React (Staff): `src/features/report/presentation/pages/staff_report_page.tsx`
- Flutter (Staff): `modules/home_module/lib/presentation/pages/staff_court_report_page.dart`
- Flutter (Admin): `modules/home_module/lib/presentation/pages/admin_dashboard_section.dart`

**Luồng chính**:
1. ADMIN mở `/admin/overview` hoặc STAFF mở `/staff/report`
2. Chọn bộ lọc: facility_id, date_range, sport_id
3. GET `/api/v1/reports/advanced-performance?facility_id=...&from=...&to=...`
4. Service aggregate dữ liệu từ Booking + Payment collections
5. Trả về: revenue_total, booking_count, top_courts, revenue_trend, utilization
6. React dùng Recharts render biểu đồ

---

## 4.3 Activity Diagram — Mô tả để vẽ lại

### AD01 — Quy trình đặt sân

**Swimlane**: Customer | Flutter App | Backend API | Database

**Các bước**:
1. [Customer] Mở app, chọn môn thể thao
2. [Customer] Chọn cơ sở
3. [Flutter] Gọi GET /facility để hiển thị danh sách
4. [Customer] Chọn sân (court)
5. [Flutter] Gọi GET /court/:id/slot-config để lấy cấu hình slot
6. [Customer] Chọn ngày + slot thời gian
7. [Flutter] Gọi GET /booking?court_id=&date= để kiểm tra slot đã có booking chưa (hiển thị màu)
8. [Customer] Nhấn "Đặt sân"
9. [Flutter] POST /booking
10. [Backend] Kiểm tra sân ACTIVE?
    - Không → Trả lỗi (kết thúc)
    - Có → tiếp tục
11. [Backend] Kiểm tra conflict booking
    - Có conflict → Trả lỗi (kết thúc)
    - Không → tiếp tục
12. [Backend] Tính giá
13. [Backend] Tạo Booking (PENDING)
14. [Backend] Tạo Payment (PENDING)
15. [Backend] Gửi thông báo cho STAFF (Socket + FCM)
16. [Flutter] Hiển thị trang hóa đơn / chọn thanh toán
17. [Customer] Chọn phương thức thanh toán
18. [Kết thúc]

**Điểm rẽ nhánh**:
- Sân không ACTIVE → kết thúc lỗi
- Có booking conflict → kết thúc lỗi
- Chọn CASH → payment sẽ do STAFF xác nhận
- Chọn ZaloPay → mở WebView ZaloPay → callback cập nhật

---

### AD02 — Quy trình duyệt/hủy booking

**Swimlane**: STAFF | React Web | Backend API | Database | Customer App

**Duyệt**:
1. [STAFF] Nhận thông báo booking mới (Socket.IO)
2. [STAFF] Mở danh sách booking PENDING
3. [STAFF] Xem chi tiết booking
4. [STAFF] Quyết định: Duyệt hoặc Hủy?
5a. [Duyệt] PUT /booking/:id/status {status: CONFIRMED}
    → Booking: PENDING → CONFIRMED
    → Thông báo CUSTOMER: "Booking đã xác nhận"
5b. [Hủy] PUT /booking/:id/cancel {cancel_reason}
    → Booking: PENDING/CONFIRMED → CANCELLED
    → Payment → CANCELLED
    → Thông báo CUSTOMER: "Booking đã bị hủy"

---

### AD03 — Quy trình quản lý hóa đơn (Payment)

**Swimlane**: Customer | Staff | Backend | ZaloPay

**Luồng CASH**:
1. [Backend] Booking được tạo → Payment PENDING (method: CASH)
2. [Staff] Xem danh sách payment PENDING trên web
3. [Staff] Thu tiền mặt từ khách
4. [Staff] Nhấn "Đã thu tiền" → PUT /payment/:id/status {status: SUCCESS}
5. [Backend] Payment → SUCCESS, Booking → CONFIRMED
6. [Backend] Thông báo Customer

**Luồng ZaloPay**:
1. [Backend] Booking → Payment PENDING (method: ZALOPAY)
2. [Customer] Chọn thanh toán ZaloPay trên mobile
3. [Customer] POST /zalopay/create-order
4. [Backend] Gọi ZaloPay API tạo order → nhận order_url
5. [Customer] Flutter mở WebView với order_url
6. [Customer] Thực hiện thanh toán trên ZaloPay
7. [ZaloPay Server] POST /zalopay/callback đến Backend
8. [Backend] Verify HMAC → Payment → SUCCESS → Booking → CONFIRMED
9. [Backend] Socket.IO thông báo Customer và Staff

---

### AD04 — Quy trình ghép trận

**Swimlane**: Customer A (Host) | Customer B (Joiner) | Backend | Cron | Database

**Manual Matching**:
1. [Customer A] Có booking, tạo MatchingSession OPEN
2. [Backend] Session lưu vào DB, trả về session_id
3. [Customer B] Tìm kiếm session trên matching_explorer_page
4. [Customer B] Tham gia session (POST /matching/:id/join)
5. [Backend] Kiểm tra slot còn không, thêm member
6. [auto_approve = true] → member APPROVED ngay
7. [auto_approve = false] → member PENDING, thông báo Host
8. [Customer A, nếu manual approve] → PUT /matching/:id/members/:userId {status: APPROVED}
9. [Backend] Kiểm tra đủ players? → Session FULL
10. [Backend] Socket.IO emit matching_session_updated cho cả phòng

**Auto Matching (Queue)**:
1. [Customer A] Vào hàng đợi (POST /matching/queue/join)
2. [Backend] MatchQueue entry tạo status: SEARCHING
3. [Customer B] Vào hàng đợi với thông số tương thích
4. [Cron Matchmaker] Chạy mỗi phút
5. [Cron] Tìm các queue tương thích (same sport, facility, date, time overlap)
6. [Cron] Đủ players → Tạo Booking tự động + MatchingSession
7. [Cron] Cập nhật queue → MATCHED
8. [Backend] Thông báo tất cả players

---

### AD05 — Quy trình lịch cố định

**Swimlane**: Customer | Backend API | Cron | Database | Staff

1. [Customer] Tạo FixedSchedule (PENDING_APPROVAL)
2. [Backend] Gửi thông báo cho Staff
3. [Staff] Duyệt hoặc từ chối
4a. [Từ chối] → REJECTED, thông báo Customer
4b. [Duyệt] → ACTIVE
5. [Backend] Sinh booking ngay cho 7 ngày tới
6. [Cron fixedScheduler, 00:05 hàng ngày] Scan all ACTIVE schedules
7. [Cron] Với mỗi schedule, generate bookings cho date range phía trước
8. [Customer] Muốn hủy một buổi?
   → POST /fixed-schedule/:id/occurrences/:date/cancel
   → Thêm exception_date, hủy booking ngày đó
9. [Customer/Staff] Muốn tạm dừng?
   → PUT /pause → PAUSED, cron bỏ qua
10. [Staff] Muốn tiếp tục?
    → PUT /resume → ACTIVE, cron tiếp tục sinh booking
11. [Kết thúc ngày end_date] → EXPIRED

---

### AD06 — Báo cáo/Thống kê

**Swimlane**: Admin/Staff | React Web | Backend | Database

1. [Admin/Staff] Đăng nhập vào Web Admin
2. [Admin] Vào `/admin/overview` hoặc [Staff] vào `/staff/report`
3. [React] Gọi GET /reports/advanced-performance (Admin) hoặc /reports/court-performance (Staff)
4. [Backend] Aggregate Booking + Payment theo facility_id, date_range
5. [Backend] Tính: total_revenue, booking_count, top_courts, utilization_rate, daily_trend
6. [React] Render Recharts: BarChart doanh thu, LineChart trend, PieChart theo sân
7. [Admin/Staff] Lọc theo cơ sở / thời gian / môn thể thao
8. [React] Gọi lại API với params mới → update chart

---

## 4.4 Sequence Diagram — Mô tả chi tiết

### SD01 — Đăng nhập

**Actors**: User → Mobile/Web → `auth.controller.js` → `user-auth.service.js` → MongoDB

1. User nhập email + password
2. **POST /api/v1/auth/sign-in** `{ email, password }`
3. `auth.controller.js::signIn()` gọi `user-auth.service.js::signIn(email, password)`
4. `user-auth.service.js` → `UserRepository::findByEmail(email)` → MongoDB User collection
5. MongoDB trả về User document
6. `bcrypt.compare(password, user.password)` → result
7. Kiểm tra `user.status === 'ACTIVE'`
8. `jwt.sign({ id, email, role }, JWT_SECRET)` → accessToken
9. `jwt.sign({ id }, JWT_REFRESH_SECRET)` → refreshToken
10. **Response 200**: `{ success: true, data: { accessToken, refreshToken, user } }`

---

### SD02 — Đặt sân

**Actors**: Customer → Flutter App → `booking.controller.js` → `booking.service.js` → `court-availability.service.js` → MongoDB → `socket-io.service.js` → FCM

1. Customer chọn slot và nhấn "Đặt sân"
2. **POST /api/v1/booking** với Authorization header
3. `auth.middleware.js::verifyToken()` → decode JWT → `req.user`
4. `booking.controller.js::createBooking()` → `booking.service.js::createBooking()`
5. Service gọi `Court.findById(court_id)` → kiểm tra ACTIVE
6. Service gọi `court-availability.service.js::checkSlotAvailable(court_id, date, start, end)` → query booking overlap
7. Service gọi `booking-price.service.js::calculatePrice()` → `price_per_hour × duration`
8. `Booking.create({ user_id, court_id, booking_date, start_minutes, end_minutes, total_price, status: 'PENDING' })`
9. `Payment.create({ booking_id, user_id, amount, method: 'CASH', status: 'PENDING' })`
10. `notification.helper.js::notifyStaffNewBooking()` → `socket-io.service.js::notifyStaff()` → emit to `room_staff`
11. FCM push (nếu có FCM token của staff)
12. **Response 201**: `{ success: true, data: { booking, payment } }`

---

### SD03 — Duyệt booking (STAFF)

**Actors**: Staff → React Web → `booking.controller.js` → `booking.service.js` → MongoDB → Socket.IO

1. Staff nhận thông báo booking mới qua Socket.IO
2. **PUT /api/v1/booking/:id/status** `{ status: 'CONFIRMED' }`
3. Middleware verify JWT + requireRole(['STAFF', 'ADMIN'])
4. `booking.controller.js::updateBookingStatus()` → `booking.service.js::updateBookingStatus()`
5. `Booking.findById(id)` → kiểm tra status === 'PENDING'
6. `Booking.updateOne({ status: 'CONFIRMED' })`
7. `notification.helper.js::notifyUserBookingConfirmed(userId)` → `socket-io.service.js::notifyUser(userId, notification)` → emit `user_${userId}`
8. FCM push đến Customer
9. **Response 200**: booking đã update

---

### SD04 — Thanh toán ZaloPay

**Actors**: Customer → Flutter → `zalopay.controller.js` → `zalopay.service.js` → ZaloPay API → ZaloPay Server → `/zalopay/callback` → MongoDB → Socket.IO

1. Customer chọn "ZaloPay" → **POST /api/v1/zalopay/create-order** `{ paymentId }`
2. Controller → Service gọi ZaloPay API: `POST https://sb-openapi.zalopay.vn/v2/create`
3. ZaloPay trả về: `{ order_url, deeplink_url, qr_code, app_trans_id }`
4. Backend lưu `transaction_id`, `zalopay_order_url`, etc. vào Payment
5. Response về Flutter: `{ order_url, deeplink_url, qr_code }`
6. Flutter mở WebView với `order_url` → Customer thanh toán
7. ZaloPay Server gọi callback: **POST /api/v1/zalopay/callback** `{ data, mac }`
8. `zalopay.controller.js::handleCallback()` → verify HMAC (không cần JWT)
9. `zalopay.service.js` → `Payment.update({ status: 'SUCCESS' })`
10. `Booking.update({ status: 'CONFIRMED' })`
11. `socket-io.service.js::notifyUser()` → emit payment success cho Customer

---

### SD05 — Tạo phòng ghép trận

**Actors**: Customer → Flutter → `matching.controller.js` → `matching.service.js` → MongoDB → Socket.IO

1. Customer POST **/api/v1/matching** `{ booking_id, sport_id, facility_id, court_id, booking_date, start_minutes, end_minutes, total_players_needed, team_mode, payment_policy, auto_approve }`
2. Middleware verify token + requireRole('CUSTOMER')
3. `matching.controller.js::createSession()` → `matching.service.js::createSession()`
4. Validate booking thuộc về host_id
5. `MatchingSession.create({ host_id, sport_id, ..., status: 'OPEN', members: [{ user_id: host_id, status: 'APPROVED' }] })`
6. **Response 201**: session object

---

### SD06 — Join phòng ghép trận

**Actors**: Customer B → Flutter → `matching.controller.js` → `matching.service.js` → MongoDB → Socket.IO → Customer A (Host)

1. Customer B POST **/api/v1/matching/:id/join** `{ join_mode, team_code, represented_count, note }`
2. `matching.service.js::joinSession()`
3. `MatchingSession.findById(id)` → check OPEN, check not FULL
4. Check user chưa là member
5. Add member với status PENDING hoặc APPROVED (tùy `auto_approve`)
6. Check tổng `represented_count` >= `total_players_needed` → `status: FULL`
7. `MatchingSession.save()`
8. `socket-io.service.js::notifyMatchingUpdate(sessionId, updatedSession)` → emit `room_matching_{id}`
9. Nếu `auto_approve = false`: notify Host để duyệt
10. **Response 200**: updated session

---

### SD07 — Fixed schedule generate booking

**Actors**: Cron `fixedScheduler` → `fixed-schedule.service.js` → MongoDB

1. Cron chạy lúc 00:05 hàng ngày (và khi startup sau 5 giây)
2. `fixedScheduleRepository.findActiveSchedules()` → tất cả FixedSchedule status ACTIVE
3. `fixedScheduleService.getAdvanceGenerationRange()` → [today, today+14days]
4. Với mỗi schedule:
   a. Tính danh sách ngày cần gen (daily hoặc weekly theo days_of_week)
   b. Bỏ qua `exception_dates`
   c. Kiểm tra booking đã tồn tại chưa (partial unique index)
   d. `Booking.create({ user_id, court_id, booking_date, start_minutes, end_minutes, fixed_schedule_id, is_fixed_schedule: true })`
5. Log kết quả

---

### SD08 — Gửi thông báo

**Actors**: Business Event → `notification.helper.js` → `notification.service.js` → MongoDB → `socket-io.service.js` → `fcm.service.js` → Firebase FCM → Mobile

1. Sự kiện xảy ra (booking confirmed, payment success, matching full...)
2. `notification.helper.js::sendNotification(userId, title, content, type, metadata)` được gọi
3. `notification.service.js::createNotification()` → `Notification.create(...)` → lưu vào MongoDB
4. `socket-io.service.js::notifyUser(userId, notification)` → emit `notification_received` + `new_notification` vào room `user_{userId}`
5. `fcm.service.js::sendToUser(userId, title, body, data)` → lấy `user.fcmTokens` → gọi Firebase Admin SDK `messaging.sendMulticast()`
6. Firebase FCM → thiết bị Android/iOS của user
7. Flutter `firebase_messaging` nhận notification → `flutter_local_notifications` hiển thị
