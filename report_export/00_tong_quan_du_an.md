# 1. THÔNG TIN TỔNG QUAN DỰ ÁN

## 1.1 Tên đề tài đề xuất

**"Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ trên nền tảng Android và Web quản trị"**

*(Tên tiếng Anh đề xuất: Sports Complex Management System with Opponent Matching Feature for Android and Web Admin Platform)*

---

## 1.2 Mục tiêu hệ thống

Hệ thống được xây dựng nhằm số hóa toàn bộ quy trình vận hành một khu liên hợp thể thao hiện đại, hướng đến các mục tiêu cụ thể sau:

| STT | Mục tiêu | Mô tả |
|-----|----------|-------|
| 1 | **Quản lý cơ sở thể thao** | Hệ thống hóa thông tin cơ sở (Facility), sân chơi (Court), và môn thể thao (Sport) theo từng địa điểm |
| 2 | **Quản lý sân và cấu hình slot** | Cấu hình thời gian mở/đóng cửa, slot thời gian, giá theo giờ; theo dõi trạng thái ACTIVE/INACTIVE/MAINTENANCE |
| 3 | **Đặt sân (Booking)** | Cho phép khách hàng đặt sân theo slot, hệ thống kiểm tra conflict tự động, hỗ trợ đặt cho khách vãng lai |
| 4 | **Lịch cố định (Fixed Schedule)** | Tạo lịch đặt sân định kỳ (DAILY/WEEKLY), duyệt bởi STAFF/ADMIN, tự động sinh booking, quản lý ngoại lệ |
| 5 | **Ghép trận/Tìm đối thủ (Matching)** | Tạo phòng ghép trận thủ công (Manual Session) hoặc tự động ghép qua hàng đợi (Auto Queue), hỗ trợ team mode |
| 6 | **Thanh toán (Payment)** | Quản lý hóa đơn theo booking, hỗ trợ nhiều phương thức (CASH, ZaloPay), tracking trạng thái thanh toán |
| 7 | **Thông báo (Notification)** | Thông báo realtime qua Socket.IO, push notification qua Firebase FCM, lưu lịch sử thông báo |
| 8 | **Báo cáo/Thống kê** | Dashboard doanh thu, hiệu suất sân, báo cáo booking theo nhiều bộ lọc cho ADMIN và STAFF |
| 9 | **Quản trị đa vai trò** | Web admin cho ADMIN/STAFF, mobile app cho CUSTOMER (và một phần STAFF/ADMIN) |

---

## 1.3 Đối tượng sử dụng

### CUSTOMER (Khách hàng)
- **Mô tả**: Người dùng cuối sử dụng ứng dụng mobile Flutter
- **Chức năng chính**:
  - Đăng ký/đăng nhập (email+OTP hoặc Firebase Auth)
  - Xem danh sách cơ sở, sân, môn thể thao
  - Đặt sân theo slot thời gian
  - Tạo/quản lý lịch cố định
  - Tìm đối thủ / tham gia phòng ghép trận
  - Thanh toán (CASH/ZaloPay)
  - Xem lịch sử booking, hóa đơn
  - Nhận thông báo realtime
  - Đánh giá (Review) sau khi sử dụng sân
  - Quản lý hồ sơ cá nhân
- **Vai trò trong code**: `role: 'CUSTOMER'` trong User model
- **Nền tảng**: Flutter Android (và iOS về mặt kỹ thuật)

### STAFF (Nhân viên)
- **Mô tả**: Nhân viên quản lý tại cơ sở thể thao, sử dụng Web React
- **Chức năng chính**:
  - Xem và quản lý booking (duyệt, hủy, hoàn thành)
  - Tạo booking cho khách vãng lai
  - Quản lý thanh toán (thu tiền mặt, cập nhật trạng thái)
  - Quản lý sân/slot cấu hình
  - Xem báo cáo hiệu suất sân
  - Duyệt lịch cố định
  - Xem matching/fixed schedule
  - Nhận thông báo realtime (Socket.IO room_staff)
- **Vai trò trong code**: `role: 'STAFF'` trong User model, `facility_id` liên kết cơ sở
- **Nền tảng**: React Web Admin + một phần màn hình staff trong Flutter

### ADMIN (Quản trị viên hệ thống)
- **Mô tả**: Quản trị toàn bộ hệ thống, sử dụng Web React
- **Chức năng chính** (bao gồm tất cả quyền STAFF và thêm):
  - Quản lý toàn bộ cơ sở, sân, môn thể thao
  - Quản lý người dùng (role, status, gán cơ sở)
  - Xem dashboard tổng quan hệ thống
  - Quản lý matching sessions và fixed schedules toàn hệ thống
  - Quản lý reviews
  - Gửi notification broadcast
  - Báo cáo nâng cao (advanced performance)
  - Duyệt/từ chối fixed schedule
- **Vai trò trong code**: `role: 'ADMIN'` trong User model
- **Nền tảng**: React Web Admin + một phần màn hình admin trong Flutter

> **Lưu ý**: Trong code Socket.IO service (`socket-io.service.js`, dòng 63), có đề cập `SUPER_ADMIN` trong điều kiện join room_admin, tuy nhiên không có enum `SUPER_ADMIN` trong User model. Thực tế hệ thống hiện tại chỉ có 3 role: **CUSTOMER, STAFF, ADMIN**.

---

## 1.4 Phạm vi hệ thống

### Mobile Flutter – Dành cho ai?
- **Chủ yếu dành cho CUSTOMER**: Đặt sân, thanh toán, ghép trận, lịch cố định, thông báo, hồ sơ
- **Có màn hình STAFF/ADMIN**: `staff_dashboard_section.dart`, `admin_dashboard_section.dart`, `admin_moderation_page.dart`, `admin_booking_supervision_page.dart`, `admin_payment_supervision_page.dart` — nhân viên và admin có thể dùng mobile để theo dõi

### Web React – Dành cho ai?
- **Dành cho STAFF và ADMIN**: Giao diện quản trị chuyên nghiệp, không phục vụ CUSTOMER
- Phân quyền rõ ràng: route `/admin/*` chỉ dành ADMIN, `/staff/*` chỉ dành STAFF

### Backend – Phục vụ nghiệp vụ gì?
- RESTful API phục vụ cả Flutter và React
- Xử lý toàn bộ business logic: booking conflict, payment state machine, matching algorithm, fixed schedule generation
- Cron jobs: auto cancel, auto complete, auto match, fixed schedule generation
- Socket.IO: realtime notification
- Firebase Admin: FCM push notification, email verification

### Chức năng đã có (hoàn thiện hoặc một phần)

| Chức năng | Trạng thái |
|-----------|-----------|
| Đăng ký / Đăng nhập | ✅ Hoàn thiện |
| Quản lý Facility/Sport/Court | ✅ Hoàn thiện |
| Đặt sân (Booking) | ✅ Hoàn thiện |
| Lịch cố định (Fixed Schedule) | ✅ Hoàn thiện |
| Ghép trận Manual | ✅ Hoàn thiện |
| Ghép trận Auto Queue | ✅ Hoàn thiện |
| Thanh toán CASH | ✅ Hoàn thiện |
| Thanh toán ZaloPay | ✅ Tích hợp (Sandbox) |
| Thông báo Socket.IO | ✅ Hoàn thiện |
| FCM Push Notification | ⚠️ Triển khai, cần serviceAccountKey production |
| Báo cáo STAFF/ADMIN | ✅ Hoàn thiện |
| Đánh giá (Review) | ✅ Một phần |
| Court Block/Maintenance | ✅ Hoàn thiện |
| Web Admin | ✅ Hoàn thiện |
| Auto cancel/complete cron | ✅ Hoàn thiện |
| Thanh toán VNPay/MoMo thật | ❌ Chưa tích hợp (có enum, chưa có controller) |
| Hoàn tiền tự động | ❌ Chưa có (REFUND_PENDING/REFUNDED có trong model, chưa auto) |
| Web Customer | ❌ Chưa có |
| iOS production | ⚠️ Build được, chưa deploy |
