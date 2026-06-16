# 1. THÔNG TIN TỔNG QUAN DỰ ÁN

## 1.1 Tên đề tài đề xuất

**Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp tính năng đặt sân, lịch cố định và ghép đối thủ trên nền tảng di động Android và web quản trị**

*(Tên đề tài phụ: "Ứng dụng Sport Energy – Quản lý cơ sở thể thao và tìm kiếm đối thủ thể thao")*

---

## 1.2 Mục tiêu hệ thống

Hệ thống hướng đến việc số hóa toàn bộ quy trình vận hành của một khu liên hợp thể thao, bao gồm:

| STT | Mục tiêu | Mô tả |
|-----|----------|-------|
| 1 | Quản lý cơ sở & sân thể thao | Quản lý thông tin cơ sở (Facility), sân (Court), môn thể thao (Sport), cấu hình slot giờ, trạng thái sân |
| 2 | Đặt sân (Booking) | Khách hàng đặt sân theo slot giờ, tự động kiểm tra xung đột, tính giá, duyệt/hủy, tự động hoàn thành |
| 3 | Lịch cố định (Fixed Schedule) | Đặt sân định kỳ (hàng tuần/hàng ngày), hệ thống tự sinh booking, quản lý ngoại lệ |
| 4 | Ghép trận / Tìm đối thủ (Matching) | Tìm đối thủ thủ công hoặc tự động, hỗ trợ nhiều chế độ đội, quản lý thành viên |
| 5 | Hóa đơn / Thanh toán (Payment) | Quản lý hóa đơn, hỗ trợ ZaloPay, tiền mặt, BANK_TRANSFER |
| 6 | Thông báo (Notification) | Thông báo real-time qua Socket.IO và push notification qua Firebase FCM |
| 7 | Báo cáo & Thống kê | Báo cáo doanh thu, hiệu suất sân, đặt sân theo cơ sở/môn/thời gian |
| 8 | Quản trị web | Giao diện web cho ADMIN và STAFF quản lý toàn bộ nghiệp vụ |
| 9 | Ứng dụng di động | App Android cho khách hàng đặt sân, xem lịch, ghép trận, nhận thông báo |

---

## 1.3 Đối tượng sử dụng

### Vai trò CUSTOMER (Khách hàng)
- **Mô tả:** Người dùng cuối, sử dụng ứng dụng Flutter Android
- **Chức năng chính:**
  - Đăng ký / đăng nhập / quên mật khẩu
  - Xem danh sách cơ sở, sân, môn thể thao
  - Đặt sân theo slot giờ
  - Xem lịch sử đặt sân, hủy booking
  - Tạo/tham gia ghép trận (Matching)
  - Đăng ký lịch cố định (Fixed Schedule)
  - Quản lý hóa đơn, thanh toán qua ZaloPay
  - Nhận thông báo real-time và push notification
  - Xem hồ sơ cá nhân, chỉnh sửa thông tin

### Vai trò STAFF (Nhân viên cơ sở)
- **Mô tả:** Nhân viên quản lý một cơ sở thể thao cụ thể, sử dụng Web Admin
- **Chức năng chính:**
  - Xem tổng quan booking theo ngày (Staff Overview)
  - Quản lý booking (duyệt, xác nhận, hủy)
  - Thanh toán tại quầy (Staff Cashier)
  - Quản lý sân, slot giờ, môn thể thao của cơ sở
  - Xem lịch cố định, phiên ghép trận
  - Xem báo cáo hiệu suất
  - Quản lý đánh giá (Review)

### Vai trò ADMIN (Quản trị viên)
- **Mô tả:** Quản trị toàn hệ thống, sử dụng Web Admin
- **Chức năng chính:**
  - Tất cả quyền của STAFF
  - Quản lý nhiều cơ sở, toàn bộ người dùng
  - Duyệt/từ chối lịch cố định
  - Quản lý Matching Sessions
  - Xem báo cáo nâng cao (Advanced Performance)
  - Gửi thông báo hệ thống
  - Phân quyền người dùng (thay đổi role, status)
  - Gán nhân viên vào cơ sở

> **Lưu ý về SUPER_ADMIN:** Trong code `court-blocks.routes.js` xuất hiện role `SUPER_ADMIN` nhưng chưa được định nghĩa trong `user.model.js`. Đây là một điểm chưa hoàn thiện hoặc đang lên kế hoạch phát triển.

---

## 1.4 Phạm vi hệ thống

### Ứng dụng Mobile Flutter (sport_management/sports_management)
- **Dành cho:** CUSTOMER
- **Nền tảng:** Android (chính), iOS (chưa được kiểm thử/đề cập)
- **Chức năng đã triển khai theo module:**
  - `authentication_module`: Đăng nhập, đăng ký, đặt lại mật khẩu
  - `booking_module`: Đặt sân, xem lịch, lịch sử booking, chi tiết booking
  - `matching_module`: Tạo phiên ghép trận, tìm kiếm, tham gia, auto-matching lobby
  - `payment_module`: Xem hóa đơn, thanh toán ZaloPay
  - `notification_module`: Nhận thông báo in-app, FCM push notification
  - `facility_module`: Xem danh sách cơ sở, chi tiết sân
  - `home_module`: Màn hình chính
  - `user_management_module`: Quản lý hồ sơ người dùng
  - `review_module`: Đánh giá dịch vụ

### Web Quản trị React (react-staff-admin)
- **Dành cho:** ADMIN và STAFF
- **Chức năng đã triển khai (theo routes):**

  **ADMIN routes:**
  - `/admin/overview` – Dashboard tổng quan (báo cáo nâng cao)
  - `/admin/facilities` – Quản lý cơ sở
  - `/admin/courts` – Quản lý sân
  - `/admin/sports` – Quản lý môn thể thao
  - `/admin/users` – Quản lý người dùng
  - `/admin/supervision` – Giám sát booking toàn hệ thống
  - `/admin/bookings/:id` – Chi tiết booking
  - `/admin/fixed-schedules` – Danh sách lịch cố định
  - `/admin/fixed-schedules/:id` – Chi tiết lịch cố định
  - `/admin/matching` – Danh sách phiên ghép trận
  - `/admin/matching/:id` – Chi tiết phiên ghép trận
  - `/admin/reviews` – Quản lý đánh giá
  - `/admin/notifications` – Quản lý thông báo
  - `/admin/profile` – Hồ sơ ADMIN

  **STAFF routes:**
  - `/staff/overview` – Tổng quan booking theo ngày
  - `/staff/bookings` – Quản lý booking
  - `/staff/bookings/:id` – Chi tiết booking
  - `/staff/cashier` – Thu ngân (thanh toán tại quầy)
  - `/staff/fixed-schedules` – Xem lịch cố định
  - `/staff/matching` – Xem phiên ghép trận
  - `/staff/reviews` – Xem đánh giá
  - `/staff/operations/slots` – Quản lý slot giờ
  - `/staff/operations/courts` – Quản lý sân
  - `/staff/operations/sports` – Quản lý môn thể thao
  - `/staff/report` – Báo cáo
  - `/staff/notifications` – Thông báo
  - `/staff/profile` – Hồ sơ STAFF

### Backend Node.js/Express (node_be_refactor)
- **Vai trò:** REST API server, WebSocket server, Cron job runner
- **Phục vụ:** Cả Flutter App và React Web Admin
- **Nghiệp vụ chính:**
  - Xác thực JWT (Access Token + Refresh Token)
  - Quản lý dữ liệu (MongoDB)
  - Xử lý booking và conflict resolution
  - Tự động sinh booking từ lịch cố định
  - Thuật toán ghép trận tự động
  - Tích hợp ZaloPay (thanh toán thật)
  - Push notification qua Firebase Admin SDK
  - Real-time notification qua Socket.IO
  - Upload ảnh qua Cloudinary
  - Gửi email OTP qua Nodemailer

### Chức năng đã hoàn thiện
- Toàn bộ luồng đăng ký/đăng nhập/quên mật khẩu
- CRUD sân, cơ sở, môn thể thao
- Đặt sân với kiểm tra xung đột
- Lịch cố định với cron tự động sinh booking
- Ghép trận thủ công và tự động
- Hóa đơn và tích hợp ZaloPay
- Thông báo in-app và FCM
- Báo cáo hiệu suất sân và doanh thu

### Chức năng còn hạn chế / chưa hoàn thiện
- SUPER_ADMIN: Khai báo trong route nhưng chưa có trong model
- Hoàn tiền tự động (REFUND): Có trường dữ liệu nhưng chưa có cổng xử lý tự động
- iOS: Chưa được đề cập/kiểm thử
- Web dành cho CUSTOMER: Chưa có
- Fixed Schedule Matching: Có cấu trúc dữ liệu nhưng tính năng cho Customer join phức tạp
- Court Block (khóa sân bảo trì): Đang triển khai một phần
