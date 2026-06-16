# 7. GIAO DIỆN NGƯỜI DÙNG

## 7.1 Danh sách màn hình Flutter Mobile

### Nhóm Auth

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Splash Screen | `lib/` (qua router) | ALL | Kiểm tra token, điều hướng | - | `hinh_splash.png` |
| Đăng nhập | `authentication_module/.../pages/` | ALL | Đăng nhập bằng email/password | `POST /auth/sign-in` | `hinh_dangnhap.png` |
| Đăng ký | `authentication_module/.../pages/` | CUSTOMER mới | Tạo tài khoản mới | `POST /auth/register` | `hinh_dangky.png` |
| Quên mật khẩu / Reset | `authentication_module/.../pages/` | ALL | Nhập OTP, đặt mật khẩu mới | `POST /auth/forgot-password` | `hinh_quenmatkhau.png` |

---

### Nhóm Home / Dashboard

| Tên màn hình | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|------|---------|-----------|----------------|
| Trang chính (Home) | `home_module/.../presentation/` | CUSTOMER | Điều hướng đến Đặt sân, Ghép trận, Lịch, Thông báo | `hinh_home.png` |

---

### Nhóm Booking (Đặt sân)

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Danh mục sân | `booking_module/.../pages/booking_catalog_full_page.dart` | CUSTOMER | Xem danh sách sân theo cơ sở | `GET /facility`, `GET /court` | `hinh_danhsachsan.png` |
| Đặt sân (Booking) | `booking_module/.../pages/court_booking_page.dart` (~65KB) | CUSTOMER | Chọn sân, ngày, slot giờ, xác nhận đặt | `GET /court/:id/slot-config`, `POST /booking` | `hinh_datsan.png` |
| Lịch sử đặt sân | `booking_module/.../pages/booking_history_page.dart` (~22KB) | CUSTOMER | Xem danh sách booking, lọc theo trạng thái | `GET /booking` | `hinh_lichsudat.png` |
| Chi tiết booking | `booking_module/.../pages/booking_detail_page.dart` (~26KB) | CUSTOMER | Xem chi tiết, hủy booking | `GET /booking/:id`, `PUT /booking/:id/cancel` | `hinh_chitietbooking.png` |

---

### Nhóm Ghép trận (Matching)

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Tìm phiên ghép trận | `matching_module/.../pages/matching_explorer_page.dart` (~37KB) | CUSTOMER | Tìm kiếm, lọc phiên ghép trận đang mở | `GET /matching` | `hinh_timgheptran.png` |
| Tạo phiên ghép trận | `matching_module/.../pages/create_matching_session_page.dart` (~85KB) | CUSTOMER | Điền form tạo session | `POST /matching` | `hinh_taogheptran.png` |
| Chi tiết phiên ghép trận | `matching_module/.../pages/matching_detail_page.dart` (~38KB) | CUSTOMER | Xem thành viên, join/leave | `GET /matching/:id`, `POST /matching/:id/join` | `hinh_chitietgheptran.png` |
| Lobby ghép tự động | `matching_module/.../pages/auto_matching_lobby_page.dart` (~30KB) | CUSTOMER | Vào hàng đợi, chờ hệ thống ghép | `POST /matching/queue/join`, `GET /matching/queue/status` | `hinh_autolobby.png` |

---

### Nhóm Payment (Hóa đơn)

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Danh sách hóa đơn | `payment_module/.../presentation/` | CUSTOMER | Xem tất cả hóa đơn | `GET /payment` | `hinh_hoadon.png` |
| Chi tiết hóa đơn / Thanh toán | `payment_module/.../presentation/` | CUSTOMER | Thanh toán ZaloPay hoặc xem trạng thái | `POST /zalopay/create-order`, `POST /zalopay/query` | `hinh_thanhtoan.png` |

---

### Nhóm Thông báo

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Danh sách thông báo | `notification_module/.../presentation/` | CUSTOMER | Xem, đánh dấu đã đọc | `GET /notification`, `PUT /notification/:id/read` | `hinh_thongbao.png` |

---

### Nhóm Hồ sơ

| Tên màn hình | File | Vai trò | Chức năng | API gọi | Gợi ý tên hình |
|-------------|------|---------|-----------|---------|----------------|
| Hồ sơ cá nhân | `user_management_module/.../presentation/` | CUSTOMER | Xem, chỉnh sửa thông tin, đổi mật khẩu, upload avatar | `GET /user/:id`, `PUT /user/:id`, `POST /upload` | `hinh_hoso.png` |

---

### Nhóm Cơ sở / Sân

| Tên màn hình | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|------|---------|-----------|----------------|
| Danh sách cơ sở | `facility_module/.../presentation/` | CUSTOMER | Xem danh sách cơ sở thể thao | `hinh_cosovathesao.png` |
| Chi tiết cơ sở / Sân | `facility_module/.../presentation/` | CUSTOMER | Xem thông tin sân, giờ hoạt động | `hinh_chitietcoso.png` |

---

### Nhóm Đánh giá

| Tên màn hình | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|------|---------|-----------|----------------|
| Gửi đánh giá | `review_module/.../presentation/` | CUSTOMER | Đánh giá sau khi sử dụng sân | `hinh_danhgia.png` |

---

## 7.2 Danh sách màn hình React Web Admin

### Nhóm Auth

| Tên màn hình | Route URL | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|----------------|
| Đăng nhập Portal | `/sign-in` | `features/auth/.../login_page.tsx` | ADMIN, STAFF | Đăng nhập với email/password, tài khoản thử nhanh | `hinh_web_dangnhap.png` |

---

### Nhóm Dashboard (ADMIN)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Dashboard Admin | `/admin/overview` | `features/report/.../admin_overview_page.tsx` | ADMIN | Tổng quan doanh thu, booking, matching với biểu đồ Recharts | `GET /reports/advanced-performance` | `hinh_web_dashboard_admin.png` |
| Tổng quan Staff | `/staff/overview` | `features/booking/.../staff_overview_page.tsx` | STAFF | Xem booking trong ngày, tổng quan vận hành | `GET /booking` | `hinh_web_dashboard_staff.png` |

---

### Nhóm Quản lý Cơ sở (ADMIN)

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Quản lý cơ sở | `/admin/facilities` | `features/facility/.../admin_facilities_page.tsx` | ADMIN | CRUD cơ sở thể thao | `GET/POST/PUT/DELETE /facility` | `hinh_web_coso.png` |
| Quản lý sân (Admin) | `/admin/courts` | `features/facility/.../admin_courts_page.tsx` | ADMIN | CRUD sân | `GET/POST/PUT/DELETE /court` | `hinh_web_san_admin.png` |
| Quản lý môn thể thao (Admin) | `/admin/sports` | `features/facility/.../admin_sports_page.tsx` | ADMIN | CRUD môn thể thao | `GET/POST/PUT/DELETE /sport` | `hinh_web_monthethao.png` |
| Quản lý sân (Staff) | `/staff/operations/courts` | `features/facility/.../staff_courts_page.tsx` | STAFF | Quản lý sân tại cơ sở | `GET/PUT /court` | `hinh_web_san_staff.png` |
| Quản lý slot giờ | `/staff/operations/slots` | `features/facility/.../staff_slots_page.tsx` | STAFF | Thiết lập giờ mở cửa, slot | `PUT /court/:id/slot-config` | `hinh_web_slot.png` |
| Quản lý môn (Staff) | `/staff/operations/sports` | `features/facility/.../staff_sports_page.tsx` | STAFF | Quản lý môn thể thao tại cơ sở | `GET/PUT /sport` | `hinh_web_monthethao_staff.png` |

---

### Nhóm Booking

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Giám sát Booking (Admin) | `/admin/supervision` | `features/booking/.../admin_supervision_page.tsx` | ADMIN | Xem tất cả booking toàn hệ thống | `GET /booking` | `hinh_web_supervision.png` |
| Quản lý Booking (Staff) | `/staff/bookings` | `features/booking/.../staff_bookings_page.tsx` | STAFF | Xem, duyệt, hủy booking tại cơ sở | `GET/PUT /booking` | `hinh_web_booking_staff.png` |
| Chi tiết Booking | `/admin(staff)/bookings/:id` | `features/booking/.../booking_detail_page.tsx` | ADMIN, STAFF | Xem chi tiết, thay đổi trạng thái | `GET/PUT /booking/:id` | `hinh_web_chitietbooking.png` |

---

### Nhóm Thanh toán

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Thu ngân (Cashier) | `/staff/cashier` | `features/payment/.../staff_cashier_page.tsx` | STAFF | Tra cứu hóa đơn, thu tiền mặt | `GET /payment`, `PUT /payment/:id/status` | `hinh_web_cashier.png` |

---

### Nhóm Lịch cố định

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Danh sách lịch cố định | `/admin(staff)/fixed-schedules` | `features/fixed_schedule/.../fixed_schedule_list_page.tsx` | ADMIN, STAFF | Xem danh sách, lọc theo trạng thái | `GET /fixed-schedule` | `hinh_web_lichcodinh_list.png` |
| Chi tiết lịch cố định | `/admin(staff)/fixed-schedules/:id` | `features/fixed_schedule/.../fixed_schedule_detail_page.tsx` | ADMIN, STAFF | Duyệt/từ chối/tạm dừng/hủy, xem booking sinh ra | `PUT /fixed-schedule/:id/approve` | `hinh_web_lichcodinh_detail.png` |

---

### Nhóm Ghép trận

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Danh sách phiên ghép trận | `/admin(staff)/matching` | `features/matching/.../matching_list_page.tsx` | ADMIN, STAFF | Xem danh sách phiên | `GET /matching` | `hinh_web_matching_list.png` |
| Chi tiết phiên ghép trận | `/admin(staff)/matching/:id` | `features/matching/.../matching_detail_page.tsx` | ADMIN, STAFF | Xem thành viên, trạng thái | `GET /matching/:id` | `hinh_web_matching_detail.png` |

---

### Nhóm Báo cáo

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Báo cáo Staff | `/staff/report` | `features/report/.../staff_report_page.tsx` | STAFF | Hiệu suất sân, doanh thu tại cơ sở | `GET /reports/court-performance` | `hinh_web_baocao_staff.png` |

---

### Nhóm Quản lý người dùng

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Quản lý người dùng | `/admin/users` | `features/user_management/.../admin_users_page.tsx` | ADMIN | Xem, phân quyền, khóa tài khoản, gán facility | `GET/PUT /user` | `hinh_web_users.png` |

---

### Nhóm Thông báo

| Tên màn hình | Route URL | File | Vai trò | Chức năng | API | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|-----|----------------|
| Thông báo Admin | `/admin/notifications` | `features/notification/.../admin_notifications_page.tsx` | ADMIN | Gửi thông báo hệ thống, xem thông báo | `GET/POST /notification` | `hinh_web_thongbao_admin.png` |
| Thông báo Staff | `/staff/notifications` | `features/notification/.../staff_notifications_page.tsx` | STAFF | Xem thông báo của Staff | `GET /notification` | `hinh_web_thongbao_staff.png` |

---

### Nhóm Đánh giá

| Tên màn hình | Route URL | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|----------------|
| Danh sách đánh giá | `/admin(staff)/reviews` | `features/review/.../review_list_page.tsx` | ADMIN, STAFF | Xem đánh giá | `hinh_web_danhgia_list.png` |
| Chi tiết đánh giá | `/admin(staff)/reviews/:id` | `features/review/.../review_detail_page.tsx` | ADMIN, STAFF | Xem chi tiết, phản hồi | `hinh_web_danhgia_detail.png` |

---

### Nhóm Hồ sơ

| Tên màn hình | Route URL | File | Vai trò | Chức năng | Gợi ý tên hình |
|-------------|-----------|------|---------|-----------|----------------|
| Hồ sơ (Admin) | `/admin/profile` | `features/auth/.../profile_page.tsx` | ADMIN | Xem/chỉnh sửa thông tin cá nhân | `hinh_web_profile.png` |
| Hồ sơ (Staff) | `/staff/profile` | `features/auth/.../profile_page.tsx` | STAFF | Xem/chỉnh sửa thông tin cá nhân | `hinh_web_profile_staff.png` |

---

## 7.3 Mô tả giao diện để đưa vào báo cáo

### Giao diện đăng nhập / đăng ký (Mobile)

Màn hình đăng nhập của ứng dụng được thiết kế tối giản, thân thiện với người dùng di động. Người dùng nhập địa chỉ email và mật khẩu vào các ô nhập liệu có nhãn rõ ràng. Nút "Đăng nhập" được đặt nổi bật ở phía dưới. Bên dưới là liên kết chuyển đến màn hình đăng ký và quên mật khẩu. Sau khi đăng nhập thành công, hệ thống tự động điều hướng đến màn hình chính và đăng ký token thiết bị để nhận thông báo đẩy.

### Giao diện đăng nhập Web Admin

Web Admin có giao diện đăng nhập riêng biệt với cổng thông tin dành cho nhân viên và quản trị viên. Trang hiển thị logo hệ thống, form đăng nhập gồm email và mật khẩu. Hỗ trợ tài khoản dùng thử nhanh (click để điền tự động). Sau khi đăng nhập, hệ thống tự động điều hướng đến dashboard phù hợp với vai trò (ADMIN → `/admin/overview`, STAFF → `/staff/overview`). Hỗ trợ chế độ Dark Mode.

### Giao diện tổng quan khách hàng (Mobile Home)

Màn hình chính của ứng dụng hiển thị menu điều hướng chính bao gồm: Đặt sân, Ghép trận, Lịch sử booking, Thông báo và Hồ sơ cá nhân. Thiết kế sử dụng bottom navigation bar và card view để dễ dàng truy cập nhanh vào các chức năng phổ biến.

### Giao diện đặt sân (Mobile)

Màn hình đặt sân là một trong những màn hình phức tạp nhất (65KB). Người dùng lần lượt chọn: (1) Cơ sở thể thao, (2) Môn thể thao, (3) Sân, (4) Ngày, (5) Slot giờ từ lưới hiển thị giờ. Các slot đã có booking được tô màu khác để phân biệt. Hệ thống tự động tính giá và hiển thị tổng tiền trước khi xác nhận. Sau khi đặt thành công, người dùng được chuyển đến màn hình chi tiết booking.

### Giao diện ghép trận (Mobile)

Giao diện ghép trận gồm hai chế độ chính:
- **Ghép thủ công (Manual Matching):** Người dùng duyệt danh sách phiên ghép trận đang mở, xem thông tin chi tiết (môn thể thao, cơ sở, giờ chơi, số người cần, chế độ đội), và nhấn "Tham gia". Host có thể duyệt hoặc từ chối từng request.
- **Ghép tự động (Auto Matching Lobby):** Người dùng nhập thông tin yêu cầu và chờ hệ thống tự động ghép. Màn hình lobby hiển thị trạng thái chờ, cron job chạy mỗi phút để kiểm tra và ghép.

### Giao diện hóa đơn / thanh toán (Mobile)

Danh sách hóa đơn hiển thị tất cả payment của người dùng với badge trạng thái màu sắc (PENDING: vàng, SUCCESS: xanh, CANCELLED: đỏ). Chi tiết hóa đơn hiển thị số tiền, phương thức, và booking liên kết. Nút "Thanh toán ZaloPay" mở WebView/App ZaloPay để thực hiện thanh toán thật.

### Giao diện dashboard Admin (Web)

Dashboard Admin tại `/admin/overview` hiển thị tổng quan toàn hệ thống với biểu đồ đường (line chart) về doanh thu theo thời gian, biểu đồ cột (bar chart) về số lượng booking, và các card số liệu tổng hợp (tổng doanh thu, tổng booking, số phiên ghép trận, số lịch cố định). Hỗ trợ bộ lọc theo khoảng thời gian và cơ sở.

### Giao diện quản lý booking (Web Staff)

Trang quản lý booking của Staff hiển thị danh sách booking dạng bảng với các cột: mã booking, khách hàng, sân, ngày giờ, giá tiền, trạng thái. Có nút lọc theo ngày, cơ sở, trạng thái. Staff có thể click vào từng booking để xem chi tiết, xác nhận hoặc hủy. Trang thu ngân (Cashier) cho phép tra cứu hóa đơn và xác nhận thu tiền mặt.

### Giao diện quản lý lịch cố định (Web)

Danh sách lịch cố định hiển thị theo bảng với thông tin: khách hàng, sân, tần suất, ngày bắt đầu, trạng thái. STAFF/ADMIN có thể click vào chi tiết để duyệt hoặc từ chối. Màn hình chi tiết hiển thị toàn bộ thông tin lịch, danh sách booking đã sinh ra, và lịch ngoại lệ.

### Giao diện báo cáo (Web)

Trang báo cáo Staff (`/staff/report`) hiển thị biểu đồ hiệu suất từng sân: số booking, doanh thu, tỷ lệ lấp đầy (occupancy rate). ADMIN có báo cáo nâng cao hơn với nhiều chỉ số tổng hợp và bộ lọc linh hoạt hơn.
