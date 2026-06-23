# 7. GIAO DIỆN NGƯỜI DÙNG

## 7.1 Danh sách màn hình Flutter Mobile

### Nhóm: Auth (Xác thực)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình báo cáo |
|-------------|---------------|---------|-----------|------------|------------------------|
| Đăng nhập | `modules/authentication_module/lib/presentation/pages/sign_in_page.dart` | CUSTOMER, STAFF, ADMIN | Nhập email+password hoặc đăng nhập Google Firebase | `POST /auth/sign-in`, `POST /auth/firebase/login` | Hình_7.1_Dang_nhat |
| Đăng ký | `modules/authentication_module/lib/presentation/pages/sign_up_page.dart` | CUSTOMER | Tạo tài khoản mới | `POST /auth/register` | Hình_7.2_Dang_ky |
| Xác thực Email | `modules/authentication_module/lib/presentation/pages/verify_email_page.dart` | CUSTOMER | Nhập OTP email | `POST /auth/verify-email`, `POST /auth/resend-verification` | Hình_7.3_Xac_thuc_email |
| Quên/Đặt lại mật khẩu | `modules/authentication_module/lib/presentation/pages/reset_password_page.dart` | CUSTOMER | Nhập OTP reset + mật khẩu mới | `POST /auth/forgot-password`, `POST /auth/reset-password` | Hình_7.4_Quen_mat_khau |

---

### Nhóm: Home/Dashboard (Trang chủ)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình báo cáo |
|-------------|---------------|---------|-----------|------------|------------------------|
| Trang chủ (Container) | `modules/home_module/lib/presentation/pages/home_page.dart` | ALL | Container điều hướng sang dashboard phù hợp role | - | - |
| Dashboard Khách hàng | `modules/home_module/lib/presentation/pages/customer_dashboard_section.dart` | CUSTOMER | Xem facility, sport, booking gần đây, notification, profile | `GET /facility`, `GET /sport`, `GET /booking`, `GET /notification` | Hình_7.5_Dashboard_KH |
| Dashboard Nhân viên | `modules/home_module/lib/presentation/pages/staff_dashboard_section.dart` | STAFF | Danh sách booking, duyệt booking, quản lý sân, báo cáo, thông báo | Nhiều API | Hình_7.6_Dashboard_NV |
| Dashboard Quản trị | `modules/home_module/lib/presentation/pages/admin_dashboard_section.dart` | ADMIN | Thống kê tổng quan, biểu đồ doanh thu | `GET /reports/advanced-performance` | Hình_7.7_Dashboard_Admin |
| Giám sát booking (Admin) | `modules/home_module/lib/presentation/pages/admin_booking_supervision_page.dart` | ADMIN | Xem toàn bộ booking hệ thống | `GET /booking` | Hình_7.8_GS_Booking |
| Kiểm duyệt người dùng (Admin) | `modules/home_module/lib/presentation/pages/admin_moderation_page.dart` | ADMIN | Quản lý user: role, status, facility | `GET/PUT /user` | Hình_7.9_QL_NguoiDung |
| Giám sát thanh toán (Admin) | `modules/home_module/lib/presentation/pages/admin_payment_supervision_page.dart` | ADMIN | Xem payment toàn hệ thống | `GET /payment` | Hình_7.10_GS_ThanhToan |
| Báo cáo sân (Staff) | `modules/home_module/lib/presentation/pages/staff_court_report_page.dart` | STAFF | Xem báo cáo hiệu suất sân theo cơ sở | `GET /reports/court-performance` | Hình_7.11_BaoCao_San |
| Cấu hình slot (Staff) | `modules/home_module/lib/presentation/pages/staff_court_slot_config_page.dart` | STAFF | Xem danh sách sân + chọn cấu hình | `GET /court`, `GET /court/:id/slot-config` | Hình_7.12_CauHinh_Slot |
| Chi tiết slot (Staff) | `modules/home_module/lib/presentation/pages/staff_court_slot_config_detail_page.dart` | STAFF | Cấu hình chi tiết slot + block | `PUT /court/:id/slot-config`, `POST /court-blocks` | Hình_7.13_ChiTiet_Slot |
| Thông tin nhân viên | `modules/home_module/lib/presentation/pages/staff_personal_information_page.dart` | STAFF | Xem/cập nhật hồ sơ, đổi mật khẩu | `GET/PUT /user/:id`, `POST /auth/change-password` | Hình_7.14_HoSo_NV |
| Cài đặt hệ thống | `modules/home_module/lib/presentation/pages/system_settings_page.dart` | ADMIN | Cấu hình hệ thống | - | Hình_7.15_CaiDat |

---

### Nhóm: Booking (Đặt sân)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình |
|-------------|---------------|---------|-----------|------------|----------------|
| Đặt sân (Trang chính) | `modules/booking_module/lib/presentation/pages/court_booking_page.dart` | CUSTOMER | Chọn facility → sport → court → date → slot → đặt sân / lịch cố định | `GET /facility`, `GET /court`, `GET /court/:id/slot-config`, `GET /booking` (check), `POST /booking`, `POST /fixed-schedule` | Hình_7.16_Dat_San |
| Danh sách booking | `modules/booking_module/lib/presentation/pages/booking_catalog_full_page.dart` | CUSTOMER | Xem tất cả booking | `GET /booking` | Hình_7.17_DS_Booking |
| Chi tiết booking | `modules/booking_module/lib/presentation/pages/booking_detail_page.dart` | CUSTOMER | Thông tin chi tiết, hủy booking, hủy một buổi fixed | `GET /booking/:id`, `PUT /booking/:id/cancel`, `POST /fixed-schedule/:id/occurrences/:date/cancel` | Hình_7.18_CT_Booking |
| Lịch sử booking | `modules/booking_module/lib/presentation/pages/booking_history_page.dart` | CUSTOMER | Lịch sử booking + lịch cố định của user | `GET /booking`, `GET /fixed-schedule` | Hình_7.19_LichSu_Booking |

---

### Nhóm: Payment/Invoice (Hóa đơn)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình |
|-------------|---------------|---------|-----------|------------|----------------|
| Chi tiết hóa đơn | `modules/payment_module/lib/presentation/pages/invoice_detail_page.dart` | CUSTOMER | Xem hóa đơn, chọn phương thức, thanh toán ZaloPay | `GET /payment`, `POST /payment`, `POST /zalopay/create-order`, `POST /zalopay/query` | Hình_7.20_HoaDon |
| WebView ZaloPay | `modules/payment_module/lib/presentation/pages/zalopay_webview_page.dart` | CUSTOMER | Trang thanh toán ZaloPay trong WebView | ZaloPay URL | Hình_7.21_ZaloPay |
| Mock Payment | `modules/payment_module/lib/presentation/pages/mock_payment_page.dart` | CUSTOMER (dev) | Mô phỏng thanh toán | `PUT /payment/:id/status` | Hình_7.22_Mock_Payment |
| Tab thanh toán | `modules/payment_module/lib/presentation/pages/payment_tab_widget.dart` | CUSTOMER | Widget tab hiển thị danh sách payment | `GET /payment` | - |

---

### Nhóm: Matching (Ghép trận)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình |
|-------------|---------------|---------|-----------|------------|----------------|
| Tạo phòng ghép trận | `modules/matching_module/lib/presentation/pages/create_matching_session_page.dart` | CUSTOMER | Form tạo session: team_mode, players_needed, payment_policy... | `POST /matching` | Hình_7.23_Tao_GhepTran |
| Khám phá phòng | `modules/matching_module/lib/presentation/pages/matching_explorer_page.dart` | CUSTOMER | Tìm kiếm phòng OPEN theo facility/sport/date | `GET /matching` | Hình_7.24_KhamPha_GhepTran |
| Chi tiết phòng | `modules/matching_module/lib/presentation/pages/matching_detail_page.dart` | CUSTOMER | Xem thành viên, tham gia, duyệt/từ chối member | `GET /matching/:id`, `POST /matching/:id/join`, `POST /matching/:id/leave`, `PUT /matching/:id/members/:userId` | Hình_7.25_CT_GhepTran |
| Hàng đợi tự động | `modules/matching_module/lib/presentation/pages/auto_matching_lobby_page.dart` | CUSTOMER | Vào hàng đợi, chờ ghép tự động, xem trạng thái | `POST /matching/queue/join`, `GET /matching/queue/status`, `POST /matching/queue/leave` | Hình_7.26_HangDoi_GhepTran |

---

### Nhóm: Notification (Thông báo)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình |
|-------------|---------------|---------|-----------|------------|----------------|
| Danh sách thông báo | `modules/notification_module/lib/presentation/widgets/` | ALL | Xem thông báo, đánh dấu đọc | `GET /notification`, `PUT /notification/:id/read` | Hình_7.27_ThongBao |

---

### Nhóm: Profile (Hồ sơ)

| Tên màn hình | Đường dẫn file | Vai trò | Chức năng | API gọi đến | Gợi ý tên hình |
|-------------|---------------|---------|-----------|------------|----------------|
| Hồ sơ cá nhân | `modules/user_management_module/lib/presentation/` | ALL | Xem/sửa thông tin, avatar, đổi mật khẩu | `GET/PUT /user/:id`, `POST /upload/image` | Hình_7.28_HoSo |

---

## 7.2 Danh sách màn hình React Web Admin

### Nhóm: Auth (Xác thực)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Đăng nhập Web | `/sign-in` | `features/auth/presentation/pages/login_page.tsx` | ADMIN, STAFF | Đăng nhập vào web admin | `POST /auth/sign-in` | Hình_8.1_Web_DangNhap |
| Hồ sơ cá nhân | `/admin/profile`, `/staff/profile` | `features/auth/presentation/pages/profile_page.tsx` | ADMIN, STAFF | Xem/sửa hồ sơ, đổi mật khẩu | `GET/PUT /user/:id` | Hình_8.2_Web_HoSo |

---

### Nhóm: Dashboard / Reports

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Tổng quan Admin | `/admin/overview` | `features/report/presentation/pages/admin_overview_page.tsx` | ADMIN | Dashboard biểu đồ doanh thu, top sân, tổng booking | `GET /reports/advanced-performance` | Hình_8.3_Web_Dashboard_Admin |
| Tổng quan Staff | `/staff/overview` | `features/booking/presentation/pages/staff_overview_page.tsx` | STAFF | Thống kê ngắn: booking hôm nay, pending, revenue | `GET /booking`, `GET /reports/court-performance` | Hình_8.4_Web_Dashboard_Staff |
| Báo cáo Staff | `/staff/report` | `features/report/presentation/pages/staff_report_page.tsx` | STAFF | Báo cáo chi tiết hiệu suất sân, doanh thu | `GET /reports/court-performance` | Hình_8.5_Web_BaoCao |

---

### Nhóm: Facility/Court/Sport (Cơ sở, Sân, Môn)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Quản lý cơ sở | `/admin/facilities` | `features/facility/presentation/pages/admin_facilities_page.tsx` | ADMIN | CRUD Facility, gán staff | `GET/POST/PUT/DELETE /facility`, `POST /user/:id/assign-facility` | Hình_8.6_Web_QL_CoSo |
| Quản lý sân (Admin) | `/admin/courts` | `features/facility/presentation/pages/admin_courts_page.tsx` | ADMIN | CRUD Court | `GET/POST/PUT/DELETE /court` | Hình_8.7_Web_QL_San |
| Quản lý môn (Admin) | `/admin/sports` | `features/facility/presentation/pages/admin_sports_page.tsx` | ADMIN | CRUD Sport | `GET/POST/PUT/DELETE /sport` | Hình_8.8_Web_QL_Mon |
| Sân (Staff) | `/staff/operations/courts` | `features/facility/presentation/pages/staff_courts_page.tsx` | STAFF | Xem/sửa court trong facility | `GET/PUT /court` | Hình_8.9_Web_San_Staff |
| Slot Config (Staff) | `/staff/operations/slots` | `features/facility/presentation/pages/staff_slots_page.tsx` | STAFF | Cấu hình slot cho sân | `GET/PUT /court/:id/slot-config` | Hình_8.10_Web_Slot |
| Môn (Staff) | `/staff/operations/sports` | `features/facility/presentation/pages/staff_sports_page.tsx` | STAFF | Xem danh sách môn | `GET /sport` | - |

---

### Nhóm: Booking (Đặt sân)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Giám sát Booking (Admin) | `/admin/supervision` | `features/booking/presentation/pages/admin_supervision_page.tsx` | ADMIN | Xem toàn bộ booking hệ thống, lọc | `GET /booking` | Hình_8.11_Web_GS_Booking |
| Quản lý Booking (Staff) | `/staff/bookings` | `features/booking/presentation/pages/staff_bookings_page.tsx` | STAFF | Duyệt booking, tạo booking mới cho walk-in | `GET /booking`, `POST /booking`, `PUT /booking/:id/status` | Hình_8.12_Web_QL_Booking |
| Chi tiết Booking | `/admin/bookings/:id`, `/staff/bookings/:id` | `features/booking/presentation/pages/booking_detail_page.tsx` | ADMIN, STAFF | Xem chi tiết, hủy, cập nhật | `GET /booking/:id`, `PUT /booking/:id/cancel`, `PUT /booking/:id/status` | Hình_8.13_Web_CT_Booking |

---

### Nhóm: Payment (Thanh toán)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Thu tiền mặt (Staff) | `/staff/cashier` | `features/payment/presentation/pages/staff_cashier_page.tsx` | STAFF | Tra cứu booking/payment, xác nhận thu tiền CASH | `GET /payment`, `PUT /payment/:id/status` | Hình_8.14_Web_Thu_Tien |

---

### Nhóm: Matching (Ghép trận)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Danh sách Matching | `/admin/matching`, `/staff/matching` | `features/matching/presentation/pages/matching_list_page.tsx` | ADMIN, STAFF | Xem danh sách session, lọc | `GET /matching` | Hình_8.15_Web_DS_Matching |
| Chi tiết Matching | `/admin/matching/:id`, `/staff/matching/:id` | `features/matching/presentation/pages/matching_detail_page.tsx` | ADMIN, STAFF | Xem chi tiết session, members, trạng thái | `GET /matching/:id` | Hình_8.16_Web_CT_Matching |

---

### Nhóm: Fixed Schedule (Lịch cố định)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Danh sách Lịch cố định | `/admin/fixed-schedules`, `/staff/fixed-schedules` | `features/fixed_schedule/presentation/pages/fixed_schedule_list_page.tsx` | ADMIN, STAFF | Danh sách, lọc theo status | `GET /fixed-schedule` | Hình_8.17_Web_DS_LichCoDinh |
| Chi tiết Lịch cố định | `/admin/fixed-schedules/:id`, `/staff/fixed-schedules/:id` | `features/fixed_schedule/presentation/pages/fixed_schedule_detail_page.tsx` | ADMIN, STAFF | Chi tiết, approve/reject/pause/resume | `GET /fixed-schedule`, `PUT /fixed-schedule/:id/approve`, `PUT /fixed-schedule/:id/reject` | Hình_8.18_Web_CT_LichCoDinh |

---

### Nhóm: User Management (Quản lý người dùng)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Quản lý người dùng | `/admin/users` | `features/user_management/presentation/pages/admin_users_page.tsx` | ADMIN | Danh sách user, sửa role/status, gán cơ sở | `GET /user`, `PUT /user/:id/role`, `PUT /user/:id/status`, `POST /user/:id/assign-facility` | Hình_8.19_Web_QL_NguoiDung |

---

### Nhóm: Notifications (Thông báo)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Thông báo Admin | `/admin/notifications` | `features/notification/presentation/pages/admin_notifications_page.tsx` | ADMIN | Xem + gửi broadcast notification | `GET /notification`, Socket.IO | Hình_8.20_Web_ThongBao_Admin |
| Thông báo Staff | `/staff/notifications` | `features/notification/presentation/pages/staff_notifications_page.tsx` | STAFF | Xem thông báo, đánh dấu đọc | `GET /notification` | Hình_8.21_Web_ThongBao_Staff |

---

### Nhóm: Reviews (Đánh giá)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Danh sách Review | `/admin/reviews`, `/staff/reviews` | `features/review/presentation/pages/review_list_page.tsx` | ADMIN, STAFF | Xem review của khách | `GET /review` | Hình_8.22_Web_Review |
| Chi tiết Review | `/admin/reviews/:id`, `/staff/reviews/:id` | `features/review/presentation/pages/review_detail_page.tsx` | ADMIN, STAFF | Chi tiết review, xóa nếu vi phạm | `GET /review/:id`, `DELETE /review/:id` | Hình_8.23_Web_CT_Review |

---

## 7.3 Mô tả giao diện để đưa vào báo cáo

### Giao diện đăng nhập/đăng ký (Flutter)
Màn hình đăng nhập (`sign_in_page.dart`) được thiết kế theo phong cách Material Design hiện đại với hai tùy chọn xác thực: đăng nhập bằng email/mật khẩu truyền thống và đăng nhập nhanh qua tài khoản Google thông qua Firebase Authentication. Màn hình đăng ký (`sign_up_page.dart`) hướng dẫn người dùng tạo tài khoản qua các bước: điền email, đặt mật khẩu, nhập tên hiển thị, sau đó chuyển tới màn hình xác thực OTP (`verify_email_page.dart`). Hệ thống gửi mã OTP 6 chữ số qua email, người dùng nhập để kích hoạt tài khoản. Màn hình quên mật khẩu (`reset_password_page.dart`) cũng theo cơ chế OTP email tương tự.

### Giao diện tổng quan khách hàng
Dashboard khách hàng (`customer_dashboard_section.dart`) là màn hình chính sau khi đăng nhập, hiển thị: danh sách cơ sở thể thao gần đây, danh sách môn thể thao có icon trực quan, các booking sắp diễn ra, và thanh thông báo nhanh. Người dùng có thể truy cập nhanh vào tính năng đặt sân, ghép trận, hoặc xem lịch sử từ tab navigation bar phía dưới.

### Giao diện đặt sân
Màn hình đặt sân (`court_booking_page.dart`, 65KB) là trang phức tạp nhất trong ứng dụng. Người dùng được hướng dẫn qua luồng nhiều bước: (1) Chọn cơ sở → (2) Chọn môn thể thao → (3) Chọn sân → (4) Chọn ngày trên calendar widget → (5) Chọn slot thời gian còn trống (hiển thị màu xanh/đỏ theo tình trạng) → (6) Xem giá → (7) Xác nhận đặt. Người dùng cũng có thể bật chế độ "Lịch cố định" để chọn tần suất DAILY/WEEKLY và các ngày trong tuần muốn đặt định kỳ.

### Giao diện hóa đơn
Trang hóa đơn chi tiết (`invoice_detail_page.dart`, 83KB) hiển thị đầy đủ thông tin: tên sân, ngày giờ, tổng tiền, trạng thái thanh toán, và các phương thức thanh toán được hỗ trợ (tiền mặt tại quầy, ZaloPay). Khi chọn ZaloPay, ứng dụng tạo đơn hàng và mở trang thanh toán ZaloPay trong WebView tích hợp (`zalopay_webview_page.dart`), giúp người dùng hoàn tất thanh toán mà không cần rời ứng dụng.

### Giao diện ghép trận
Có 4 màn hình chính cho tính năng ghép trận: (1) `matching_explorer_page.dart` — trang khám phá các phòng đang OPEN với bộ lọc facility/sport/date; (2) `create_matching_session_page.dart` — form tạo phòng với nhiều tùy chọn nâng cao như team_mode, payment_policy, auto_approve; (3) `matching_detail_page.dart` — xem danh sách thành viên theo đội A/B, tham gia/rời phòng, duyệt thành viên (nếu là host); (4) `auto_matching_lobby_page.dart` — giao diện chờ ghép trận tự động với animation loading và polling trạng thái queue.

### Giao diện lịch cố định
Tính năng lịch cố định được tích hợp trong trang đặt sân. Người dùng bật toggle "Đặt lịch cố định", sau đó chọn tần suất và ngày trong tuần. Sau khi tạo, lịch sẽ hiển thị trong tab lịch sử booking với trạng thái PENDING_APPROVAL cho đến khi STAFF duyệt. Người dùng cũng có thể xem chi tiết lịch cố định để hủy một buổi cụ thể hoặc hủy toàn bộ chuỗi.

### Giao diện thông báo
Thông báo được nhận theo thời gian thực qua Socket.IO (khi app đang chạy) và qua FCM push notification (khi app ở background hoặc đã đóng). Màn hình thông báo hiển thị danh sách có phân loại: BOOKING, PAYMENT, SYSTEM, PROMOTION. Mỗi thông báo có badge đã đọc/chưa đọc và có thể tap để navigate đến màn hình liên quan.

### Giao diện hồ sơ
Màn hình hồ sơ cho phép người dùng cập nhật tên, số điện thoại, và ảnh đại diện (qua `image_picker` + upload Cloudinary). STAFF cũng có màn hình hồ sơ riêng (`staff_personal_information_page.dart`) với thông tin cơ sở phụ trách và tùy chọn đổi mật khẩu.

### Giao diện quản trị/staff dashboard (Web)
Giao diện Web Admin được xây dựng bằng Ant Design với layout sidebar-content. Sidebar hiển thị menu động theo role: ADMIN thấy toàn bộ menu quản lý hệ thống, STAFF thấy menu nghiệp vụ tại cơ sở. Header có toggle Dark/Light mode, icon thông báo (Socket.IO realtime), và avatar người dùng. Dashboard ADMIN (`admin_overview_page.tsx`) hiển thị các widget thống kê tổng hợp và biểu đồ Recharts. Dashboard STAFF (`staff_overview_page.tsx`) tập trung vào booking hôm nay và pending cần xử lý.

### Giao diện quản lý sân (Web)
Trang `admin_courts_page.tsx` hiển thị bảng danh sách sân với các cột: tên sân, cơ sở, môn thể thao, trạng thái (chip màu), giá/giờ, và nút hành động. Có thể tạo sân mới, cập nhật thông tin, hoặc thay đổi trạng thái trực tiếp. Trang `staff_slots_page.tsx` cho phép STAFF xem và cấu hình slot thời gian cho từng sân.

### Giao diện quản lý booking (Web)
Trang `staff_bookings_page.tsx` là giao diện chính của STAFF với bảng booking có bộ lọc đa chiều: status, ngày, sân, khách hàng. STAFF có thể duyệt (CONFIRMED), hủy booking ngay từ bảng hoặc vào chi tiết. Trang chi tiết (`booking_detail_page.tsx`) hiển thị đầy đủ thông tin booking + payment + lịch sử thay đổi.

### Giao diện báo cáo (Web)
Trang báo cáo ADMIN (`admin_overview_page.tsx`) hiển thị: biểu đồ doanh thu theo ngày (BarChart), tỷ lệ hiệu suất sân (PieChart), top sân có doanh thu cao nhất, xu hướng booking. Trang báo cáo STAFF (`staff_report_page.tsx`) tập trung vào hiệu suất các sân trong facility mình quản lý với bộ lọc ngày linh hoạt.

### Giao diện matching/fixed schedule trên web
Trang danh sách matching (`matching_list_page.tsx`) cho phép ADMIN/STAFF xem và lọc các session theo status (OPEN/FULL/CANCELLED/COMPLETED), facility, date. Chi tiết session (`matching_detail_page.tsx`) hiển thị danh sách thành viên theo đội và thông tin booking liên kết. Trang lịch cố định (`fixed_schedule_list_page.tsx`) hiển thị bảng với badge status màu sắc. Trang chi tiết (`fixed_schedule_detail_page.tsx`) là nơi STAFF/ADMIN thực hiện approve/reject/pause với form lý do.
