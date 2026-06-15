# Development Log - Sport Energy CRM

## Nhật ký phát triển

*   2026-05-28 - Khởi tạo dự án, thiết lập TypeScript và Tailwind CSS - Hoàn thành
*   2026-05-28 - Thiết lập cấu trúc thư mục Clean Architecture `/src/core` và `/src/features` - Hoàn thành
*   2026-05-28 - Hiện thực Theme, Router, Guards, Main Layout và API client (Mock API) - Hoàn thành
*   2026-05-28 - Phân hệ Auth: Giao diện đăng nhập cao cấp, profile và session storage - Hoàn thành
*   2026-05-28 - Phân hệ Booking: Sơ đồ timelines ca đấu trực quan cho Staff, Đặt lịch quầy vãng lai với chuỗi giao dịch 5 bước - Hoàn thành
*   2026-05-28 - Phân hệ Facility, Sân đấu và Môn thể thao: Trang CRUD của Admin, trang xem của Staff và màn hình cấu hình ca đấu (Slots) có đầy đủ validate - Hoàn thành
*   2026-05-28 - Phân hệ Cashier & Thu ngân: Quản lý hóa đơn chờ thu tiền, thanh toán tại quầy - Hoàn thành
*   2026-05-28 - Phân hệ Thành viên: Bảng thành viên, phân quyền trực tiếp, khóa tài khoản và tạo nhanh Staff - Hoàn thành
*   2026-05-28 - Phân hệ Báo cáo: Vẽ biểu đồ cột và tròn bằng Recharts cho Admin và Staff - Hoàn thành
*   2026-05-28 - Kiểm thử biên dịch toàn bộ dự án và hoàn thiện cấu hình - Hoàn thành
*   2026-05-28 - Sửa lỗi định tuyến bất đồng bộ khi đăng nhập, cập nhật cơ chế versioning db mock v2 giải quyết xung đột localStorage - Hoàn thành
*   2026-05-28 - Biên soạn và đồng bộ hóa tài liệu API chi tiết dành cho Admin và Staff (api-admin-staff.md) - Hoàn thành
*   2026-05-28 - Đổi cổng API mặc định thành localhost:3000/api/v1 theo đúng môi trường chạy thật - Hoàn thành
*   2026-05-28 - Khắc phục lỗi vòng lặp điều hướng gây chớp nháy màn hình khi đăng nhập tài khoản nhân viên chưa được gán cơ sở - Hoàn thành
*   2026-05-28 - Khắc phục lỗi mapping dữ liệu ca đấu từ API `/slot-config` (ánh xạ trường `mode` thành `isAvailable`, tạo `slotIndex` tự động) sửa lỗi trùng lặp React key và "Ca undefined" - Hoàn thành
*   2026-05-28 - Khắc phục lỗi Đăng ký nhanh Nhân viên tại Trang quản lý thành viên (truyền mật khẩu mặc định "123456" và cập nhật thông tin qua endpoint `/user/:id` đúng đặc tả API) - Hoàn thành
*   2026-05-28 - Khắc phục hoàn toàn lỗi Đăng ký nhanh Nhân viên (đồng bộ API `/auth/register` của backend trả về `userId`, cấu hình request/response interceptors để chuẩn hóa key Họ tên/Avatar giữa front-back, tự động kích hoạt tài khoản nhân viên mới lên `ACTIVE`) - Hoàn thành
*   2026-05-28 - Khắc phục lỗi không gán được môn thể thao cho Sân đấu của Admin (cấu hình Axios Response Interceptor tự động ánh xạ đối tượng `sport` từ API thành các trường phẳng `sportId` và `sportName` cho sân đấu) - Hoàn thành
*   2026-05-28 - Khắc phục lỗi tự động nhảy về sân đấu đầu tiên khi chọn sân đấu khác tại màn hình Cấu hình ca đấu nhân viên (memoize đối tượng `user` tránh re-trigger hàm load danh sách sân và sử dụng hàm cập nhật state an toàn) - Hoàn thành
*   2026-05-28 - Khắc phục lỗi không hiển thị Lịch đặt của Khách hàng trên CRM Web (cấu hình Axios Response Interceptor tự động ánh xạ phẳng các đối tượng liên kết `court` -> `courtId`, `user` -> `userId`, `booking` -> `bookingId` nhận từ backend) - Hoàn thành
*   2026-05-29 - Tích hợp hệ thống thông báo thời gian thực (Socket.IO, Web Audio API chime sound, khay thông báo dropdown) và các trang quản trị thông báo cho Staff và Admin - Hoàn thành




