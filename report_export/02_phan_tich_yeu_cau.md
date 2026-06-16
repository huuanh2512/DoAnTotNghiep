# 3. PHÂN TÍCH YÊU CẦU HỆ THỐNG

## 3.1 Tác nhân hệ thống

| Tác nhân | Mô tả | Chức năng chính | Quyền truy cập |
|----------|-------|-----------------|----------------|
| **CUSTOMER** | Người dùng cuối sử dụng app Android | Đặt sân, xem lịch, ghép trận, thanh toán | Chỉ truy cập tài nguyên của chính mình |
| **STAFF** | Nhân viên quản lý một cơ sở | Duyệt booking, thanh toán tại quầy, quản lý vận hành | Truy cập dữ liệu cơ sở được gán |
| **ADMIN** | Quản trị viên toàn hệ thống | Quản lý tất cả cơ sở, người dùng, báo cáo nâng cao | Toàn quyền hệ thống |
| **SUPER_ADMIN** | Quản trị cấp cao (dự kiến) | Quản lý Court Block, tác vụ cấp hệ thống | Khai báo trong court-blocks.routes.js nhưng chưa có trong model |

---

## 3.2 Yêu cầu chức năng

### Nhóm tài khoản và phân quyền

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 1.1 | Đăng ký | Tạo tài khoản mới với email/password | CUSTOMER | `POST /api/v1/auth/register` | SignUpPage | ✅ Hoàn thành |
| 1.2 | Đăng nhập | Xác thực email/password, nhận JWT | ALL | `POST /api/v1/auth/sign-in` | SignInPage, LoginPage | ✅ Hoàn thành |
| 1.3 | Làm mới token | Dùng refresh token để lấy access token mới | ALL | `POST /api/v1/auth/refresh-token` | Interceptor tự động | ✅ Hoàn thành |
| 1.4 | Đăng xuất | Hủy token, xóa session | ALL | `POST /api/v1/auth/sign-out` | Logout button | ✅ Hoàn thành |
| 1.5 | Quên mật khẩu | Gửi OTP qua email | ALL | `POST /api/v1/auth/forgot-password` | ResetPasswordPage | ✅ Hoàn thành |
| 1.6 | Đặt lại mật khẩu | Xác minh OTP và đặt mật khẩu mới | ALL | `POST /api/v1/auth/reset-password` | ResetPasswordPage | ✅ Hoàn thành |
| 1.7 | Đổi mật khẩu | Đổi mật khẩu khi đã đăng nhập | ALL | `POST /api/v1/auth/change-password` | ProfilePage | ✅ Hoàn thành |
| 1.8 | Xem hồ sơ | Xem thông tin người dùng | ALL | `GET /api/v1/user/:id` | ProfilePage | ✅ Hoàn thành |
| 1.9 | Cập nhật hồ sơ | Chỉnh sửa name, phone, avatar | ALL | `PUT /api/v1/user/:id` | ProfilePage | ✅ Hoàn thành |
| 1.10 | Phân quyền user | ADMIN thay đổi role người dùng | ADMIN | `PUT /api/v1/user/:id/role` | AdminUsersPage | ✅ Hoàn thành |
| 1.11 | Khóa/mở tài khoản | ADMIN thay đổi status user | ADMIN | `PUT /api/v1/user/:id/status` | AdminUsersPage | ✅ Hoàn thành |
| 1.12 | Gán nhân viên vào cơ sở | Liên kết STAFF với Facility | ADMIN | `POST /api/v1/user/:id/assign-facility` | AdminUsersPage | ✅ Hoàn thành |
| 1.13 | Đăng ký FCM Token | Đăng ký token thiết bị để nhận push notification | CUSTOMER | `POST /api/v1/user/register-fcm` | Tự động khi mở app | ✅ Hoàn thành |

---

### Nhóm quản lý cơ sở, sân, môn thể thao

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 2.1 | Xem danh sách cơ sở | Lấy danh sách Facility | ALL | `GET /api/v1/facility` | FacilityListPage, AdminFacilitiesPage | ✅ Hoàn thành |
| 2.2 | Xem chi tiết cơ sở | Chi tiết Facility | ALL | `GET /api/v1/facility/:id` | FacilityDetailPage | ✅ Hoàn thành |
| 2.3 | Tạo cơ sở | Tạo Facility mới | ADMIN | `POST /api/v1/facility` | AdminFacilitiesPage | ✅ Hoàn thành |
| 2.4 | Cập nhật cơ sở | Sửa thông tin Facility | ADMIN, STAFF | `PUT /api/v1/facility/:id` | AdminFacilitiesPage | ✅ Hoàn thành |
| 2.5 | Xóa cơ sở | Xóa Facility | ADMIN | `DELETE /api/v1/facility/:id` | AdminFacilitiesPage | ✅ Hoàn thành |
| 2.6 | Xem danh sách sân | Lọc sân theo facility, sport | ALL | `GET /api/v1/court` | BookingPage, AdminCourtsPage | ✅ Hoàn thành |
| 2.7 | Tạo sân | Tạo Court mới | ADMIN, STAFF | `POST /api/v1/court` | AdminCourtsPage, StaffCourtsPage | ✅ Hoàn thành |
| 2.8 | Cập nhật sân | Sửa thông tin, trạng thái sân | ADMIN, STAFF | `PUT /api/v1/court/:id` | AdminCourtsPage | ✅ Hoàn thành |
| 2.9 | Xóa sân | Xóa Court | ADMIN, STAFF | `DELETE /api/v1/court/:id` | AdminCourtsPage | ✅ Hoàn thành |
| 2.10 | Xem cấu hình slot giờ | Xem slot_config của sân | ALL | `GET /api/v1/court/:id/slot-config` | BookingPage | ✅ Hoàn thành |
| 2.11 | Cập nhật cấu hình slot giờ | Thiết lập giờ mở cửa, đóng cửa, slot | ADMIN, STAFF | `PUT /api/v1/court/:id/slot-config` | StaffSlotsPage | ✅ Hoàn thành |
| 2.12 | Xem danh sách môn thể thao | Lấy danh sách Sport | ALL | `GET /api/v1/sport` | BookingPage, AdminSportsPage | ✅ Hoàn thành |
| 2.13 | Tạo môn thể thao | Tạo Sport mới | ADMIN, STAFF | `POST /api/v1/sport` | AdminSportsPage | ✅ Hoàn thành |
| 2.14 | Cập nhật môn thể thao | Sửa thông tin Sport | ADMIN, STAFF | `PUT /api/v1/sport/:id` | AdminSportsPage | ✅ Hoàn thành |
| 2.15 | Xóa môn thể thao | Xóa Sport | ADMIN, STAFF | `DELETE /api/v1/sport/:id` | AdminSportsPage | ✅ Hoàn thành |
| 2.16 | Tạo Court Block | Khóa sân/slot bảo trì | STAFF, ADMIN | `POST /api/v1/court-blocks` | Chưa có trang riêng trên web | ⚠️ Một phần |
| 2.17 | Quản lý Court Block | Xem/cập nhật/hủy khóa sân | STAFF, ADMIN | `GET/PATCH/DELETE /api/v1/court-blocks/*` | Chưa có trang riêng trên web | ⚠️ Một phần |

---

### Nhóm đặt sân

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 3.1 | Tạo đặt sân | Chọn sân, ngày, slot giờ, tạo booking | CUSTOMER, STAFF, ADMIN | `POST /api/v1/booking` | CourtBookingPage | ✅ Hoàn thành |
| 3.2 | Kiểm tra trùng lịch | Tự động khi tạo booking | Hệ thống | `booking.service.js` | Ẩn trong luồng | ✅ Hoàn thành |
| 3.3 | Tính giá | Tính total_price theo slot giờ | Hệ thống | `booking-price.service.js` | Hiển thị trước khi xác nhận | ✅ Hoàn thành |
| 3.4 | Xem danh sách booking | Lọc theo trạng thái, ngày, sân | ALL | `GET /api/v1/booking` | BookingHistoryPage, StaffBookingsPage | ✅ Hoàn thành |
| 3.5 | Xem chi tiết booking | Chi tiết một booking | ALL | `GET /api/v1/booking/:id` | BookingDetailPage | ✅ Hoàn thành |
| 3.6 | Duyệt/cập nhật trạng thái booking | Xác nhận, hoàn thành booking | ADMIN, STAFF | `PUT /api/v1/booking/:id/status` | StaffBookingsPage, AdminSupervisionPage | ✅ Hoàn thành |
| 3.7 | Hủy booking | CUSTOMER tự hủy, STAFF/ADMIN hủy | ALL | `PUT /api/v1/booking/:id/cancel` | BookingDetailPage, StaffBookingsPage | ✅ Hoàn thành |
| 3.8 | Tự động hủy booking quá hạn | Cron job hủy booking PENDING không được xác nhận | Hệ thống (Cron) | `cron-auto-cancel-bookings.js` | Không có UI | ✅ Hoàn thành |
| 3.9 | Tự động hoàn thành booking | Cron job chuyển trạng thái sang COMPLETED | Hệ thống (Cron) | `cron-auto-complete-bookings.js` | Không có UI | ✅ Hoàn thành |

---

### Nhóm lịch cố định

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 4.1 | Tạo lịch cố định | Đăng ký lịch đặt sân định kỳ | CUSTOMER | `POST /api/v1/fixed-schedule` | Chưa thấy trong Flutter | ⚠️ Backend xong |
| 4.2 | Xem danh sách lịch cố định | Xem tất cả lịch cố định | ALL | `GET /api/v1/fixed-schedule` | FixedScheduleListPage (web) | ✅ Web xong |
| 4.3 | Duyệt lịch cố định | ADMIN/STAFF phê duyệt | ADMIN, STAFF | `PUT /api/v1/fixed-schedule/:id/approve` | FixedScheduleDetailPage | ✅ Web xong |
| 4.4 | Từ chối lịch cố định | ADMIN/STAFF từ chối | ADMIN, STAFF | `PUT /api/v1/fixed-schedule/:id/reject` | FixedScheduleDetailPage | ✅ Web xong |
| 4.5 | Tạm dừng lịch | Tạm dừng chuỗi booking định kỳ | CUSTOMER, ADMIN | `PUT /api/v1/fixed-schedule/:id/pause` | FixedScheduleDetailPage | ✅ Hoàn thành |
| 4.6 | Tiếp tục lịch | Tiếp tục chuỗi đã tạm dừng | CUSTOMER, ADMIN | `PUT /api/v1/fixed-schedule/:id/resume` | FixedScheduleDetailPage | ✅ Hoàn thành |
| 4.7 | Hủy lịch | Hủy toàn bộ chuỗi | CUSTOMER, ADMIN | `PUT /api/v1/fixed-schedule/:id/cancel` | FixedScheduleDetailPage | ✅ Hoàn thành |
| 4.8 | Hủy một buổi | Đánh dấu ngoại lệ một ngày | CUSTOMER | `POST /api/v1/fixed-schedule/:id/occurrences/:date/cancel` | FixedScheduleDetailPage | ✅ Hoàn thành |
| 4.9 | Sinh booking tự động | Cron job sinh booking từ lịch cố định ACTIVE | Hệ thống (Cron) | `cron-fixed-scheduler.js`, `fixed-schedule.service.js` | Không có UI | ✅ Hoàn thành |
| 4.10 | Join Fixed Matching | Tham gia lịch ghép trận cố định | CUSTOMER | `POST /api/v1/fixed-schedule/:id/matching/join` | Chưa thấy trong Flutter | ⚠️ Backend xong |
| 4.11 | Leave Fixed Matching | Rời khỏi lịch ghép trận cố định | CUSTOMER | `POST /api/v1/fixed-schedule/:id/matching/leave` | Chưa thấy trong Flutter | ⚠️ Backend xong |

---

### Nhóm ghép trận / tìm kiếm đối thủ

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 5.1 | Tạo phiên ghép trận | Tạo MatchingSession từ booking có sẵn | CUSTOMER | `POST /api/v1/matching` | CreateMatchingSessionPage | ✅ Hoàn thành |
| 5.2 | Tìm kiếm phiên ghép trận | Lọc phiên theo sport, facility, ngày | ALL | `GET /api/v1/matching` | MatchingExplorerPage | ✅ Hoàn thành |
| 5.3 | Xem chi tiết phiên | Xem danh sách thành viên, trạng thái | ALL | `GET /api/v1/matching/:id` | MatchingDetailPage | ✅ Hoàn thành |
| 5.4 | Tham gia phiên (thủ công) | Join vào MatchingSession | CUSTOMER | `POST /api/v1/matching/:id/join` | MatchingDetailPage | ✅ Hoàn thành |
| 5.5 | Rời phiên | Leave khỏi MatchingSession | CUSTOMER | `POST /api/v1/matching/:id/leave` | MatchingDetailPage | ✅ Hoàn thành |
| 5.6 | Duyệt/từ chối thành viên | Host phê duyệt request join | CUSTOMER (host) | `PUT /api/v1/matching/:id/members/:userId` | MatchingDetailPage | ✅ Hoàn thành |
| 5.7 | Cập nhật trạng thái phiên | OPEN/FULL/CANCELLED | CUSTOMER (host) | `PUT /api/v1/matching/:id/status` | MatchingDetailPage | ✅ Hoàn thành |
| 5.8 | Tham gia hàng đợi ghép tự động | Join MatchQueue để hệ thống ghép | CUSTOMER | `POST /api/v1/matching/queue/join` | AutoMatchingLobbyPage | ✅ Hoàn thành |
| 5.9 | Rời hàng đợi ghép tự động | Leave MatchQueue | CUSTOMER | `POST /api/v1/matching/queue/leave` | AutoMatchingLobbyPage | ✅ Hoàn thành |
| 5.10 | Xem trạng thái hàng đợi | Polling trạng thái queue | CUSTOMER | `GET /api/v1/matching/queue/status` | AutoMatchingLobbyPage | ✅ Hoàn thành |
| 5.11 | Ghép tự động (Cron) | Thuật toán tự ghép theo sport/facility/ngày | Hệ thống (Cron) | `cron-matchmaker.js`, `matching.service.js` | Không có UI | ✅ Hoàn thành |
| 5.12 | Chế độ TEAM_VS_TEAM | Ghép đội đấu đội | CUSTOMER | Trong matching model | CreateMatchingSessionPage | ✅ Hoàn thành |
| 5.13 | TEAM_REPRESENTATIVE | Đại diện đội tham gia | CUSTOMER | `join_mode: TEAM_REPRESENTATIVE` | CreateMatchingSessionPage | ✅ Hoàn thành |
| 5.14 | Payment policy ghép trận | HOST_PAY_ALL / SPLIT_EQUALLY / TEAM_REPRESENTATIVES_SPLIT | CUSTOMER | `payment_policy` trong model | CreateMatchingSessionPage | ✅ Cấu trúc có |

---

### Nhóm hóa đơn / thanh toán

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 6.1 | Xem danh sách payment | Lọc payment của user | ALL | `GET /api/v1/payment` | PaymentListPage (Flutter), StaffCashierPage | ✅ Hoàn thành |
| 6.2 | Tạo payment/invoice | Tạo hóa đơn cho booking | ALL | `POST /api/v1/payment` | Tự động khi xác nhận booking | ✅ Hoàn thành |
| 6.3 | Cập nhật trạng thái payment | Chuyển PENDING→SUCCESS/CANCELLED | ADMIN, STAFF, CUSTOMER | `PUT /api/v1/payment/:id/status` | StaffCashierPage | ✅ Hoàn thành |
| 6.4 | Thanh toán ZaloPay | Tạo đơn hàng ZaloPay, xử lý callback | CUSTOMER | `POST /api/v1/zalopay/create-order` | PaymentPage (Flutter) | ✅ Hoàn thành |
| 6.5 | Polling ZaloPay | Kiểm tra trạng thái đơn hàng | CUSTOMER | `POST /api/v1/zalopay/query` | PaymentPage (Flutter) | ✅ Hoàn thành |
| 6.6 | ZaloPay Callback | Webhook nhận kết quả từ ZaloPay | Hệ thống | `POST /api/v1/zalopay/callback` | Không có UI | ✅ Hoàn thành |
| 6.7 | Hoàn tiền (Refund) | Ghi nhận hoàn tiền | ADMIN, STAFF | `status: REFUNDED` trong model | Chưa thấy trang riêng | ⚠️ Cấu trúc có |
| 6.8 | Thanh toán tiền mặt | STAFF xác nhận thu tiền mặt | STAFF | `PUT /api/v1/payment/:id/status` + `method: CASH` | StaffCashierPage | ✅ Hoàn thành |

---

### Nhóm thông báo

| STT | Chức năng | Mô tả | Vai trò | Backend API | Flutter/Web | Trạng thái |
|-----|-----------|-------|---------|------------|-------------|------------|
| 7.1 | Xem danh sách thông báo | Lấy thông báo của user | ALL | `GET /api/v1/notification` | NotificationsPage (Flutter), AdminNotificationsPage | ✅ Hoàn thành |
| 7.2 | Đánh dấu đã đọc | Đọc một thông báo | ALL | `PUT /api/v1/notification/:id/read` | NotificationsPage | ✅ Hoàn thành |
| 7.3 | Đánh dấu tất cả đã đọc | Đọc toàn bộ thông báo | ALL | `PUT /api/v1/notification/mark-all-read` | NotificationsPage | ✅ Hoàn thành |
| 7.4 | Gửi thông báo hệ thống | ADMIN tạo thông báo broadcast | ADMIN | `POST /api/v1/notification` | AdminNotificationsPage | ✅ Hoàn thành |
| 7.5 | Real-time notification | Socket.IO gửi thông báo khi user online | Hệ thống | `socket-io.service.js` | Socket listener trong Flutter | ✅ Hoàn thành |
| 7.6 | Push notification FCM | Gửi notification khi user offline | Hệ thống | `fcm.service.js`, `notification.helper.js` | firebase_messaging | ✅ Hoàn thành (cần key thật) |

---

### Nhóm báo cáo / thống kê

| STT | Chức năng | Mô tả | Vai trò | Backend API | Web | Trạng thái |
|-----|-----------|-------|---------|------------|-----|------------|
| 8.1 | Báo cáo hiệu suất sân | Tổng hợp booking theo sân, giờ | STAFF, ADMIN | `GET /api/v1/reports/court-performance` | StaffReportPage | ✅ Hoàn thành |
| 8.2 | Báo cáo nâng cao | Doanh thu, booking, matching, fixed schedule | ADMIN | `GET /api/v1/reports/advanced-performance` | AdminOverviewPage | ✅ Hoàn thành |

---

## 3.3 Yêu cầu phi chức năng

| STT | Yêu cầu | Mô tả | Giải pháp áp dụng |
|-----|---------|-------|-------------------|
| 1 | **Bảo mật** | Xác thực người dùng an toàn | JWT Access Token + Refresh Token; bcrypt cho password |
| 2 | **Phân quyền** | Kiểm soát truy cập theo vai trò | `auth.middleware.js`: `verifyToken` + `requireRole()` |
| 3 | **Hiệu năng** | API response nhanh | MongoDB index trên các trường hay query (user_id, status, booking_date) |
| 4 | **Tính toàn vẹn dữ liệu** | Tránh đặt sân trùng lịch | Compound unique index trên (court_id, booking_date, start_minutes, status) |
| 5 | **Khả năng mở rộng** | Thêm cơ sở, sân, môn thể thao dễ dàng | Cấu trúc dữ liệu tham chiếu linh hoạt; module-based architecture |
| 6 | **Real-time** | Thông báo tức thì cho người dùng | Socket.IO với user rooms, staff rooms, matching rooms |
| 7 | **Tự động hóa** | Giảm thao tác thủ công | 4 Cron Jobs tự động chạy nền |
| 8 | **Trải nghiệm người dùng** | UI thân thiện | Flutter Material Design; Ant Design Web; dark mode support |
| 9 | **Logging** | Ghi log lỗi | `console.error` trong cron jobs và services; error handler middleware |
| 10 | **Xử lý lỗi** | Phản hồi lỗi chuẩn | `response.util.js` chuẩn hóa format `{ success, message, code }` |
| 11 | **Upload media** | Lưu trữ ảnh đáng tin cậy | Cloudinary CDN |
| 12 | **Email** | Gửi OTP đặt lại mật khẩu | Nodemailer |
| 13 | **Thanh toán thật** | Tích hợp cổng thanh toán | ZaloPay với HMAC xác thực webhook |
| 14 | **Multi-device** | Nhận thông báo trên nhiều thiết bị | fcmTokens là mảng, Socket.IO có thể kết nối nhiều socket cùng user |
