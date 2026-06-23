# 3. PHÂN TÍCH YÊU CẦU HỆ THỐNG

## 3.1 Tác nhân hệ thống

| Tác nhân | Mô tả | Chức năng chính | Quyền truy cập |
|----------|-------|-----------------|----------------|
| **CUSTOMER** | Người dùng cuối, sử dụng mobile app Flutter | Đặt sân, ghép trận, thanh toán, lịch cố định, thông báo, đánh giá | API: Auth, Booking (tạo/xem/hủy/own), Payment (own), Matching (join/leave/create), FixedSchedule (tạo/own), Notification (own), Review (tạo/own) |
| **STAFF** | Nhân viên cơ sở thể thao, dùng Web React | Duyệt/hủy booking, thu tiền, cấu hình sân/slot, xem báo cáo, duyệt lịch cố định | API: Booking (all trong facility), Court (CRUD), Payment (update status CASH), Reports (facility level), FixedSchedule (approve/reject/pause/resume) |
| **ADMIN** | Quản trị hệ thống, dùng Web React | Quản lý toàn bộ: cơ sở, sân, người dùng, booking, matching, báo cáo nâng cao | Toàn bộ API, bao gồm: Facility (CRUD), User (role/status/assign), Reports (system-wide), Notification (broadcast) |
| **Hệ thống (Cron)** | Các tác vụ nền tự động | Auto cancel booking quá hạn, auto complete booking đã qua giờ, ghép trận tự động, sinh booking lịch cố định | Truy cập trực tiếp Service layer, không qua API |
| **ZaloPay Server** | Cổng thanh toán bên ngoài | Callback kết quả thanh toán | POST `/api/v1/zalopay/callback` (xác thực HMAC, không cần JWT) |

---

## 3.2 Yêu cầu chức năng

### Nhóm tài khoản và phân quyền

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Đăng ký | Đăng ký bằng email+mật khẩu, gửi OTP xác thực | CUSTOMER | `POST /api/v1/auth/register` | `sign_up_page.dart` | Không có | ✅ Hoàn thành |
| Xác thực email | Nhập OTP xác thực email | CUSTOMER | `POST /api/v1/auth/verify-email` | `verify_email_page.dart` | Không có | ✅ Hoàn thành |
| Đăng nhập email | Đăng nhập email+mật khẩu, nhận JWT | CUSTOMER, STAFF, ADMIN | `POST /api/v1/auth/sign-in` | `sign_in_page.dart` | `login_page.tsx` | ✅ Hoàn thành |
| Đăng nhập Firebase | Đăng nhập qua Firebase Auth (Google) | CUSTOMER | `POST /api/v1/auth/firebase/login` | `sign_in_page.dart` | Không có | ✅ Hoàn thành |
| Refresh token | Làm mới Access Token | Tất cả | `POST /api/v1/auth/refresh-token` | Tự động trong API service | Tự động | ✅ Hoàn thành |
| Đăng xuất | Xóa token | Tất cả | `POST /api/v1/auth/sign-out` | `sign_in_page.dart` | `login_page.tsx` | ✅ Hoàn thành |
| Quên mật khẩu | Gửi OTP reset password qua email | CUSTOMER | `POST /api/v1/auth/forgot-password` | `reset_password_page.dart` | Không có | ✅ Hoàn thành |
| Đặt lại mật khẩu | Nhập OTP + mật khẩu mới | CUSTOMER | `POST /api/v1/auth/reset-password` | `reset_password_page.dart` | Không có | ✅ Hoàn thành |
| Đổi mật khẩu | Đổi mật khẩu khi đã đăng nhập | Tất cả | `POST /api/v1/auth/change-password` | `staff_personal_information_page.dart` | `profile_page.tsx` | ✅ Hoàn thành |
| Xem hồ sơ | Xem thông tin cá nhân | Tất cả | `GET /api/v1/user/:id` | `customer_dashboard_section.dart` | `profile_page.tsx` | ✅ Hoàn thành |
| Cập nhật hồ sơ | Cập nhật tên, số điện thoại, avatar | Tất cả | `PUT /api/v1/user/:id` | `customer_dashboard_section.dart` | `profile_page.tsx` | ✅ Hoàn thành |
| Phân quyền user | Thay đổi role của user | ADMIN | `PUT /api/v1/user/:id/role` | `admin_moderation_page.dart` | `admin_users_page.tsx` | ✅ Hoàn thành |
| Kích hoạt/khóa user | Thay đổi status ACTIVE/BANNED | ADMIN | `PUT /api/v1/user/:id/status` | `admin_moderation_page.dart` | `admin_users_page.tsx` | ✅ Hoàn thành |
| Gán cơ sở cho staff | Liên kết STAFF với Facility | ADMIN | `POST /api/v1/user/:id/assign-facility` | `admin_moderation_page.dart` | `admin_users_page.tsx` | ✅ Hoàn thành |
| Đăng ký FCM token | Đăng ký token để nhận push notification | CUSTOMER | `POST /api/v1/user/register-fcm` | Tự động khi login | Không có | ✅ Hoàn thành |

---

### Nhóm quản lý cơ sở, sân, môn thể thao

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Xem danh sách cơ sở | Lấy danh sách facility | Tất cả | `GET /api/v1/facility` | `customer_dashboard_section.dart` | `admin_facilities_page.tsx` | ✅ Hoàn thành |
| Tạo cơ sở | Thêm facility mới | ADMIN | `POST /api/v1/facility` | Không có | `admin_facilities_page.tsx` | ✅ Hoàn thành |
| Cập nhật cơ sở | Sửa thông tin facility | ADMIN, STAFF | `PUT /api/v1/facility/:id` | Không có | `admin_facilities_page.tsx` | ✅ Hoàn thành |
| Xóa cơ sở | Xóa facility | ADMIN | `DELETE /api/v1/facility/:id` | Không có | `admin_facilities_page.tsx` | ✅ Hoàn thành |
| Quản lý môn thể thao | CRUD Sport | ADMIN | `GET/POST/PUT/DELETE /api/v1/sport` | `customer_dashboard_section.dart` | `admin_sports_page.tsx`, `staff_sports_page.tsx` | ✅ Hoàn thành |
| Xem danh sách sân | Lấy danh sách court theo facility | Tất cả | `GET /api/v1/court` | `court_booking_page.dart` | `admin_courts_page.tsx`, `staff_courts_page.tsx` | ✅ Hoàn thành |
| Tạo sân | Thêm court mới | ADMIN, STAFF | `POST /api/v1/court` | Không có | `admin_courts_page.tsx` | ✅ Hoàn thành |
| Cập nhật sân | Sửa thông tin, status, giá | ADMIN, STAFF | `PUT /api/v1/court/:id` | Không có | `staff_courts_page.tsx` | ✅ Hoàn thành |
| Cấu hình slot | Thiết lập giờ mở/đóng, duration slot | ADMIN, STAFF | `GET/PUT /api/v1/court/:id/slot-config` | `staff_court_slot_config_page.dart` | `staff_slots_page.tsx` | ✅ Hoàn thành |
| Quản lý block/bảo trì | Tạo block thời gian cho sân | ADMIN, STAFF | `GET/POST /api/v1/court-blocks`, `DELETE /api/v1/court-blocks/:id` | `staff_court_slot_config_detail_page.dart` | Không có trực tiếp | ✅ Hoàn thành |

---

### Nhóm đặt sân

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Tạo booking | Đặt sân theo slot thời gian | CUSTOMER, STAFF, ADMIN | `POST /api/v1/booking` | `court_booking_page.dart` | `staff_bookings_page.tsx` | ✅ Hoàn thành |
| Kiểm tra trùng lịch | Validate conflict trước khi tạo | Tự động | Trong `booking.service.js` | Tự động | Tự động | ✅ Hoàn thành |
| Tính giá tự động | Tính giá dựa trên slot duration và price_per_hour | Tự động | `booking-price.service.js` | Hiển thị trên UI | Hiển thị trên UI | ✅ Hoàn thành |
| Xem danh sách booking | Lọc theo trạng thái, ngày, sân | Tất cả | `GET /api/v1/booking` | `booking_history_page.dart` | `staff_bookings_page.tsx`, `admin_supervision_page.tsx` | ✅ Hoàn thành |
| Xem chi tiết booking | Thông tin đầy đủ booking | Tất cả | `GET /api/v1/booking/:id` | `booking_detail_page.dart` | `booking_detail_page.tsx` | ✅ Hoàn thành |
| Duyệt booking | CONFIRMED booking đang PENDING | STAFF, ADMIN | `PUT /api/v1/booking/:id/status` | `staff_dashboard_section.dart` | `staff_bookings_page.tsx` | ✅ Hoàn thành |
| Hủy booking | Hủy với lý do | CUSTOMER (own), STAFF, ADMIN | `PUT /api/v1/booking/:id/cancel` | `booking_detail_page.dart` | `booking_detail_page.tsx` | ✅ Hoàn thành |
| Tự động hủy PENDING | Hủy booking PENDING quá 15 phút không thanh toán | Hệ thống (Cron) | `cron-auto-cancel-bookings.js` | Không có UI | Không có UI | ✅ Hoàn thành |
| Tự động hoàn thành | COMPLETED booking đã qua giờ chơi | Hệ thống (Cron) | `cron-auto-complete-bookings.js` | Không có UI | Không có UI | ✅ Hoàn thành |
| Lịch sử booking | Xem lịch sử booking của user | CUSTOMER | `GET /api/v1/booking?user_id=...` | `booking_history_page.dart` | Không có | ✅ Hoàn thành |

---

### Nhóm lịch cố định

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Tạo lịch cố định | Tạo lịch đặt sân định kỳ (DAILY/WEEKLY) | CUSTOMER | `POST /api/v1/fixed-schedule` | `court_booking_page.dart` | Không có (chỉ xem) | ✅ Hoàn thành |
| Xem danh sách | Lọc fixed schedules | Tất cả | `GET /api/v1/fixed-schedule` | `booking_history_page.dart` | `fixed_schedule_list_page.tsx` | ✅ Hoàn thành |
| Duyệt lịch cố định | ACTIVE fixed schedule | STAFF, ADMIN | `PUT /api/v1/fixed-schedule/:id/approve` | `staff_dashboard_section.dart` | `fixed_schedule_detail_page.tsx` | ✅ Hoàn thành |
| Từ chối lịch cố định | REJECTED + lý do | STAFF, ADMIN | `PUT /api/v1/fixed-schedule/:id/reject` | `staff_dashboard_section.dart` | `fixed_schedule_detail_page.tsx` | ✅ Hoàn thành |
| Tạm dừng | PAUSED, dừng sinh booking | STAFF, ADMIN | `PUT /api/v1/fixed-schedule/:id/pause` | `staff_dashboard_section.dart` | `fixed_schedule_detail_page.tsx` | ✅ Hoàn thành |
| Tiếp tục | ACTIVE lại từ PAUSED | STAFF, ADMIN | `PUT /api/v1/fixed-schedule/:id/resume` | Không rõ | `fixed_schedule_detail_page.tsx` | ✅ Hoàn thành |
| Hủy lịch cố định | CANCELLED toàn bộ chuỗi | Tất cả (owner) | `PUT /api/v1/fixed-schedule/:id/cancel` | `booking_history_page.dart` | `fixed_schedule_detail_page.tsx` | ✅ Hoàn thành |
| Hủy một buổi | CANCELLED một ngày cụ thể (exception_date) | CUSTOMER | `POST /api/v1/fixed-schedule/:id/occurrences/:date/cancel` | `booking_detail_page.dart` | Không có | ✅ Hoàn thành |
| Sinh booking tự động | Generate booking từ fixed schedule | Hệ thống (Cron) | `cron-fixed-scheduler.js`, `fixed-schedule.service.js` | Không có UI | Không có UI | ✅ Hoàn thành |
| Join lịch matching | Tham gia lịch ghép trận cố định | CUSTOMER | `POST /api/v1/fixed-schedule/:id/matching/join` | Chưa rõ màn hình riêng | Không có | ⚠️ Một phần |
| Leave lịch matching | Rời lịch ghép trận cố định | CUSTOMER | `POST /api/v1/fixed-schedule/:id/matching/leave` | Chưa rõ màn hình riêng | Không có | ⚠️ Một phần |

---

### Nhóm ghép trận/tìm kiếm đối thủ

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Tạo phòng ghép trận | Tạo MatchingSession thủ công | CUSTOMER | `POST /api/v1/matching` | `create_matching_session_page.dart` | Chỉ xem | ✅ Hoàn thành |
| Xem danh sách session | Tìm kiếm phòng mở | Tất cả | `GET /api/v1/matching` | `matching_explorer_page.dart` | `matching_list_page.tsx` | ✅ Hoàn thành |
| Xem chi tiết session | Thông tin phòng + members | Tất cả | `GET /api/v1/matching/:id` | `matching_detail_page.dart` | `matching_detail_page.tsx` | ✅ Hoàn thành |
| Tham gia phòng | Join MatchingSession | CUSTOMER | `POST /api/v1/matching/:id/join` | `matching_detail_page.dart` | Không có | ✅ Hoàn thành |
| Rời phòng | Leave MatchingSession | CUSTOMER | `POST /api/v1/matching/:id/leave` | `matching_detail_page.dart` | Không có | ✅ Hoàn thành |
| Duyệt/từ chối thành viên | Host approve/reject member | CUSTOMER (host) | `PUT /api/v1/matching/:id/members/:userId` | `matching_detail_page.dart` | Không có | ✅ Hoàn thành |
| Cập nhật trạng thái session | Host đổi OPEN/CANCELLED | CUSTOMER (host) | `PUT /api/v1/matching/:id/status` | `matching_detail_page.dart` | Không có | ✅ Hoàn thành |
| Vào hàng đợi auto match | Join MatchQueue | CUSTOMER | `POST /api/v1/matching/queue/join` | `auto_matching_lobby_page.dart` | Không có | ✅ Hoàn thành |
| Rời hàng đợi | Leave MatchQueue | CUSTOMER | `POST /api/v1/matching/queue/leave` | `auto_matching_lobby_page.dart` | Không có | ✅ Hoàn thành |
| Xem trạng thái hàng đợi | Kiểm tra đã được ghép chưa | CUSTOMER | `GET /api/v1/matching/queue/status` | `auto_matching_lobby_page.dart` | Không có | ✅ Hoàn thành |
| Ghép trận tự động | Cron chạy mỗi phút, ghép queue entries | Hệ thống | `cron-matchmaker.js`, `matching.service.js::runMatchmakerAlgorithm` | Không có UI | Không có UI | ✅ Hoàn thành |
| Team mode | Hỗ trợ INDIVIDUAL/TEAM_FILL/TEAM_VS_TEAM | CUSTOMER | Tham số trong create session | `create_matching_session_page.dart` | `matching_detail_page.tsx` | ✅ Hoàn thành |
| Team representative | Đại diện đội (represented_count > 1) | CUSTOMER | Tham số join_mode TEAM_REPRESENTATIVE | `create_matching_session_page.dart` | Không có | ✅ Hoàn thành |
| Payment policy | HOST_PAY_ALL / SPLIT_EQUALLY / TEAM_REPRESENTATIVES_SPLIT | CUSTOMER (host) | Tham số trong create session | `create_matching_session_page.dart` | `matching_detail_page.tsx` | ✅ Hoàn thành (định nghĩa) |

---

### Nhóm hóa đơn/thanh toán

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Tạo payment | Tạo hóa đơn cho booking | CUSTOMER, STAFF, ADMIN | `POST /api/v1/payment` | `invoice_detail_page.dart` | Tự động | ✅ Hoàn thành |
| Xem danh sách payment | Lọc payment | Tất cả | `GET /api/v1/payment` | `invoice_detail_page.dart`, `payment_tab_widget.dart` | `staff_cashier_page.tsx` | ✅ Hoàn thành |
| Cập nhật trạng thái | PENDING → SUCCESS/CANCELLED | CUSTOMER, STAFF, ADMIN | `PUT /api/v1/payment/:id/status` | `invoice_detail_page.dart` | `staff_cashier_page.tsx` | ✅ Hoàn thành |
| Thanh toán tiền mặt | CASH payment bởi STAFF | STAFF | `PUT /api/v1/payment/:id/status` | Không có | `staff_cashier_page.tsx` | ✅ Hoàn thành |
| Tạo đơn ZaloPay | Gọi ZaloPay API tạo order | CUSTOMER | `POST /api/v1/zalopay/create-order` | `invoice_detail_page.dart` | Không có | ✅ Sandbox |
| Xem ZaloPay WebView | Hiển thị trang thanh toán ZaloPay | CUSTOMER | (redirect URL) | `zalopay_webview_page.dart` | Không có | ✅ Sandbox |
| ZaloPay callback | Nhận kết quả từ ZaloPay server | Hệ thống | `POST /api/v1/zalopay/callback` | Không có UI | Không có UI | ✅ Sandbox |
| Query ZaloPay status | Polling trạng thái từ Flutter | CUSTOMER | `POST /api/v1/zalopay/query` | `invoice_detail_page.dart` | Không có | ✅ Sandbox |
| Mock payment | Mô phỏng thanh toán không ZaloPay | CUSTOMER (dev) | Không cần API | `mock_payment_page.dart` | Không có | ✅ Dev only |
| REFUND | Hoàn tiền | STAFF, ADMIN | Enum REFUNDED có trong model | Không có màn hình riêng | Không có | ⚠️ Chưa đầy đủ |

---

### Nhóm thông báo

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Xem danh sách thông báo | Lấy notification của user | Tất cả | `GET /api/v1/notification` | `notification_module/presentation/widgets` | `staff_notifications_page.tsx`, `admin_notifications_page.tsx` | ✅ Hoàn thành |
| Đánh dấu đã đọc | isRead = true | Tất cả | `PUT /api/v1/notification/:id/read` | Tự động khi xem | Tự động | ✅ Hoàn thành |
| Realtime qua Socket.IO | Emit notification khi sự kiện xảy ra | Hệ thống | `socket-io.service.js` | Lắng nghe socket | Lắng nghe socket | ✅ Hoàn thành |
| FCM Push Notification | Gửi push khi app background/closed | Hệ thống | `fcm.service.js`, Firebase Admin | `firebase_messaging` | Không có | ⚠️ Cần serviceAccountKey production |
| Broadcast notification | Gửi cho nhiều user / nhóm | ADMIN | `notification.helper.js::sendGroupNotification` | Không có | `admin_notifications_page.tsx` | ✅ Hoàn thành |

---

### Nhóm báo cáo/thống kê

| Chức năng | Mô tả | Vai trò | Backend API | Màn hình Flutter | Màn hình Web | Trạng thái |
|-----------|-------|---------|-------------|-----------------|--------------|-----------|
| Báo cáo hiệu suất sân | Booking count, revenue, utilization rate theo court | STAFF, ADMIN | `GET /api/v1/reports/court-performance` | `staff_court_report_page.dart` | `staff_report_page.tsx` | ✅ Hoàn thành |
| Báo cáo nâng cao | Revenue trend, top courts, top sports, daily stats | ADMIN | `GET /api/v1/reports/advanced-performance` | `admin_dashboard_section.dart` | `admin_overview_page.tsx` | ✅ Hoàn thành |
| Dashboard STAFF | Booking hôm nay, pending, revenue ca | STAFF | Tổng hợp nhiều API | `staff_dashboard_section.dart` | `staff_overview_page.tsx` | ✅ Hoàn thành |
| Dashboard ADMIN | Tổng quan hệ thống, biểu đồ | ADMIN | Nhiều API | `admin_dashboard_section.dart` | `admin_overview_page.tsx` | ✅ Hoàn thành |

---

## 3.3 Yêu cầu phi chức năng

### Bảo mật
- **JWT Authentication**: Mọi API đều yêu cầu Bearer Token (trừ public routes đăng ký/đăng nhập và ZaloPay callback)
- **Role-based Authorization**: Middleware `requireRole(['ADMIN', 'STAFF'])` bảo vệ các API nhạy cảm
- **Password Hashing**: bcrypt với salt rounds đảm bảo mật khẩu không lưu plaintext
- **OTP Email Verification**: Hash OTP trước khi lưu, có thời gian hết hạn
- **HMAC Verification**: ZaloPay callback xác thực bằng HMAC-SHA256 (không dùng JWT)
- **Secure Storage**: Flutter dùng `flutter_secure_storage` để lưu token an toàn trên thiết bị
- **Chú ý hiện tại**: `serviceAccountKey.json` (Firebase) phải được giữ bí mật, không commit lên git (đã có `.gitignore`)

### Phân quyền
- 3 role rõ ràng: `CUSTOMER`, `STAFF`, `ADMIN`
- STAFF được gán với Facility cụ thể (`facility_id` trong User model)
- Web React có `PrivateGuard` kiểm tra role trước khi render route
- Flutter kiểm tra role từ JWT payload để hiển thị đúng dashboard section

### Hiệu năng
- **Database Index**: Booking, Payment, MatchingSession, FixedSchedule đều có compound index tối ưu query phổ biến
- **Partial Filter Index**: Payment dùng partial filter `{status: {$in: ['PENDING', 'SUCCESS']}}` để unique constraint chỉ cho trạng thái active
- **TanStack React Query**: Cache dữ liệu phía web admin, tránh fetch lại không cần thiết
- **Cron Guard**: Mỗi cron có `isRunning` flag tránh chạy đồng thời (single-instance safe)

### Khả năng mở rộng
- Kiến trúc phân lớp rõ ràng (Controller-Service-Repository) dễ mở rộng từng lớp
- Modular Flutter với từng feature là module độc lập
- Socket.IO rooms hỗ trợ scale theo user/group
- Cần thêm: Redis pub/sub, load balancer, PM2 cluster khi scale horizontally

### Tính ổn định
- **Cron Status Tracking**: `cron-status.js` theo dõi trạng thái từng cron job
- **Health Check Endpoints**: `/health` và `/health/cron` để monitoring
- **Error Handling Middleware**: Express error handler trả về 500 chuẩn
- **Startup Scan**: Fixed scheduler chạy sau 5 giây khởi động để không bỏ lịch

### Tính toàn vẹn dữ liệu
- **Unique Constraint Index**: Payment (booking_id + user_id, partial), Booking (fixed_schedule trùng lịch), MatchingSession (host + time slot)
- **Pre-validate Hook**: CourtBlock kiểm tra start_time < end_time
- **Conflict Detection**: Booking service kiểm tra trùng lịch trước khi tạo

### Khả năng bảo trì
- Code tách lớp rõ ràng, dễ đọc
- Có ghi log chi tiết trong cron jobs
- Các file markdown tài liệu nội bộ (README, POSTMAN guides, IMPLEMENTATION_GUIDE...)
- Có script smoke test: `matching-smoke.js`, `booking-access-smoke.js`, `court-performance-report-smoke.js`

### Trải nghiệm người dùng
- Mobile Flutter: Material Design, smooth animations (implied)
- Web Admin: Ant Design components, dark/light mode toggle
- Realtime update: Socket.IO giảm độ trễ thông báo
- ZaloPay WebView: In-app payment không cần mở trình duyệt ngoài

### Logging / Error Handling
- Console.log/error có [CRON][...] prefix cho cron jobs
- Express global error handler tại `main.js`
- `cron-status.js` lưu lịch sử chạy của từng cron
