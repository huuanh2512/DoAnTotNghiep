# BÁO CÁO TỔNG HỢP: HỆ THỐNG QUẢN LÝ KHU LIÊN HỢP THỂ THAO

**Tên đề tài**: Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ trên nền tảng Android và Web quản trị  
**Ngày xuất**: 2025  
**Nguồn phân tích**: Mã nguồn thực tế (không sửa code)

---

> **Lưu ý bảo mật**: Tài liệu này không chứa bất kỳ giá trị nhạy cảm nào (không có `.env`, secret key, token, password, serviceAccountKey, credentials). Chỉ liệt kê TÊN biến môi trường và mục đích sử dụng.

---

# MỤC LỤC

1. [Thông tin tổng quan dự án](#1-thông-tin-tổng-quan-dự-án)
2. [Công nghệ và kiến trúc](#2-công-nghệ-và-kiến-trúc)
3. [Phân tích yêu cầu hệ thống](#3-phân-tích-yêu-cầu-hệ-thống)
4. [Thiết kế hệ thống — Use Case, Activity, Sequence](#4-thiết-kế-hệ-thống)
5. [Thiết kế dữ liệu và ERD](#5-thiết-kế-dữ-liệu-và-erd)
6. [Thiết kế API](#6-thiết-kế-api)
7. [Giao diện người dùng](#7-giao-diện-người-dùng)
8. [Nghiệp vụ chi tiết](#8-nghiệp-vụ-chi-tiết)
9. [Cron Job, Socket.IO và Notification](#9-cron-job-socketio-và-notification)
10. [Triển khai và môi trường](#10-triển-khai-và-môi-trường)
11. [Đánh giá hiện trạng và kiến nghị](#11-đánh-giá-hiện-trạng-và-kiến-nghị)
12. [Nội dung viết sẵn cho báo cáo](#12-nội-dung-viết-sẵn-cho-báo-cáo)

---

*(Đây là file tổng hợp — nội dung chi tiết của từng phần xem trong các file riêng lẻ)*

---

# 1. THÔNG TIN TỔNG QUAN DỰ ÁN

> **File chi tiết**: [00_tong_quan_du_an.md](./00_tong_quan_du_an.md)

## Tên đề tài đề xuất

**"Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ trên nền tảng Android và Web quản trị"**

## Các thành phần hệ thống

| Thành phần | Công nghệ | Vai trò |
|-----------|-----------|---------|
| Backend API | Node.js + Express.js + MongoDB | RESTful API, business logic, cron jobs, Socket.IO |
| Mobile App | Flutter (Android primary) | Ứng dụng khách hàng (CUSTOMER) |
| Web Admin | React + TypeScript + Ant Design | Quản trị (ADMIN + STAFF) |
| Database | MongoDB Atlas | Lưu trữ dữ liệu |
| Realtime | Socket.IO | Thông báo thời gian thực |
| Push Notification | Firebase FCM | Push notification |
| Payment | ZaloPay (Sandbox) | Thanh toán trực tuyến |
| Storage | Cloudinary | Lưu trữ ảnh |

## Đối tượng sử dụng

- **CUSTOMER**: Khách hàng, dùng Flutter Android
- **STAFF**: Nhân viên cơ sở, dùng React Web
- **ADMIN**: Quản trị hệ thống, dùng React Web (+ một phần Flutter)

## Chức năng chủ đạo

| STT | Chức năng | Trạng thái |
|-----|-----------|-----------|
| 1 | Đặt sân (Booking) | ✅ Hoàn thiện |
| 2 | Lịch cố định (Fixed Schedule) | ✅ Hoàn thiện |
| 3 | Ghép trận/Tìm đối thủ (Matching) | ✅ Hoàn thiện |
| 4 | Thanh toán (CASH + ZaloPay) | ✅ Hoàn thiện (Sandbox) |
| 5 | Thông báo Realtime | ✅ Hoàn thiện |
| 6 | Báo cáo/Thống kê | ✅ Hoàn thiện |
| 7 | Web Admin ADMIN/STAFF | ✅ Hoàn thiện |
| 8 | Auto-cancel/complete Cron | ✅ Hoàn thiện |

---

# 2. CÔNG NGHỆ VÀ KIẾN TRÚC

> **File chi tiết**: [01_cong_nghe_kien_truc.md](./01_cong_nghe_kien_truc.md)

## Stack công nghệ

| Layer | Công nghệ | Thư viện/Package chính |
|-------|-----------|----------------------|
| Backend | Node.js + Express.js | `express ^4.19.2`, `mongoose ^8.24.0`, `socket.io ^4.7.2`, `node-cron ^4.2.1`, `jsonwebtoken ^9.0.3`, `firebase-admin ^13.10.0`, `cloudinary ^1.41.3`, `bcrypt ^6.0.0`, `nodemailer ^8.0.10` |
| Mobile | Flutter (Dart ^3.12.0) | `flutter_bloc ^8.1.6`, `get_it ^8.0.2`, `go_router ^14.2.0`, `dio ^5.7.0`, `flutter_secure_storage ^9.2.2`, `firebase_messaging ^15.1.3`, `socket_io_client ^2.0.3`, `webview_flutter ^4.9.0` |
| Web Admin | React ^19.2.6 + TypeScript ^4.9.5 | `antd ^6.4.3`, `@tanstack/react-query ^5.100.14`, `react-router-dom ^7.15.1`, `axios ^1.16.1`, `socket.io-client ^4.7.5`, `recharts ^3.8.1` |

## Sơ đồ kiến trúc tổng thể

```
Flutter Android              React Web Admin
(CUSTOMER + STAFF/ADMIN)     (ADMIN + STAFF)
        |                           |
        └─────────────┬─────────────┘
              HTTPS REST API + WSS
                       |
              Node.js + Express.js
              (Controller-Service-Repository-Model)
              (Cron Jobs + Socket.IO)
                       |
          ┌────────────┼────────────┐
          ▼            ▼            ▼
       MongoDB     Firebase     Cloudinary
       Atlas       FCM/Auth     Images
                       |
                    ZaloPay
                    Gmail SMTP
```

## Kiến trúc Flutter

**Pattern**: Clean Architecture + BLoC/Cubit + Dependency Injection (get_it)

**Modules**:
- `authentication_module` — Đăng ký, đăng nhập, OTP, Firebase Auth
- `booking_module` — Đặt sân, lịch sử, lịch cố định
- `matching_module` — Ghép trận manual + auto queue
- `payment_module` — Hóa đơn, ZaloPay WebView
- `home_module` — Dashboard CUSTOMER/STAFF/ADMIN
- `notification_module` — Thông báo Socket.IO + FCM
- `facility_module` — Xem cơ sở/sân
- `user_management_module` — Hồ sơ, tài khoản
- `review_module` — Đánh giá sân

## Kiến trúc Backend

**Pattern**: Controller → Service → Repository → Model

```
src/
├── routes/        # API routing + middleware
├── controllers/   # Request handling
├── services/      # Business logic (38KB-77KB mỗi file lớn)
├── repositories/  # MongoDB queries
├── models/        # Mongoose schemas
├── middlewares/   # JWT auth, Role guard, Multer
└── utils/         # Cron jobs, response util
```

---

# 3. PHÂN TÍCH YÊU CẦU HỆ THỐNG

> **File chi tiết**: [02_phan_tich_yeu_cau.md](./02_phan_tich_yeu_cau.md)

## Tác nhân hệ thống

| Tác nhân | Mô tả | Platform |
|----------|-------|---------|
| CUSTOMER | Khách hàng | Flutter Android |
| STAFF | Nhân viên cơ sở | React Web |
| ADMIN | Quản trị viên | React Web |
| Hệ thống (Cron) | Tác vụ tự động | Backend Node.js |
| ZaloPay Server | Callback thanh toán | External service |

## Yêu cầu chức năng tóm tắt

- **30+ Use Cases** từ UC01 (Đăng ký) đến UC30 (Quản lý matching)
- Các nhóm chức năng: Tài khoản, Facility/Court/Sport, Booking, Fixed Schedule, Matching, Payment, Notification, Report

## Yêu cầu phi chức năng

| Phi chức năng | Giải pháp |
|---------------|----------|
| Bảo mật | JWT + bcrypt + OTP + HMAC ZaloPay + flutter_secure_storage |
| Phân quyền | Role-based middleware (`requireRole`) |
| Hiệu năng | MongoDB compound index, partial filter index, TanStack Query cache |
| Tính ổn định | Cron status tracking, health check, startup scan |
| Tính toàn vẹn | Unique constraint, pre-validate hook, conflict detection |

---

# 4. THIẾT KẾ HỆ THỐNG

> **File chi tiết**: [03_usecase_activity_sequence.md](./03_usecase_activity_sequence.md)

## Use Case chính

| Mã | Use Case | Tác nhân |
|----|---------|---------|
| UC01-UC02 | Đăng ký + Xác thực OTP | CUSTOMER |
| UC03 | Đăng nhập (email/Firebase) | CUSTOMER, STAFF, ADMIN |
| UC04 | Đặt sân | CUSTOMER, STAFF |
| UC05 | Duyệt booking | STAFF, ADMIN |
| UC06 | Hủy booking | CUSTOMER/STAFF/ADMIN |
| UC07 | Thanh toán hóa đơn | CUSTOMER (ZaloPay), STAFF (CASH) |
| UC09 | Tạo lịch cố định | CUSTOMER |
| UC10 | Duyệt lịch cố định | STAFF, ADMIN |
| UC11 | Hủy một buổi lịch | CUSTOMER |
| UC13 | Tạo phòng ghép trận | CUSTOMER |
| UC14 | Tham gia phòng ghép trận | CUSTOMER |
| UC16 | Ghép trận tự động | CUSTOMER |
| UC20-UC21 | Xem báo cáo | ADMIN, STAFF |

## Activity Diagram mô tả

- **AD01**: Quy trình đặt sân (Swimlane: Customer | Flutter | Backend | DB)
- **AD02**: Quy trình duyệt/hủy booking (STAFF)
- **AD03**: Quy trình thanh toán (CASH + ZaloPay)
- **AD04**: Quy trình ghép trận (Manual + Auto)
- **AD05**: Quy trình lịch cố định
- **AD06**: Quy trình báo cáo

## Sequence Diagram mô tả

- **SD01**: Đăng nhập → JWT
- **SD02**: Đặt sân → Conflict check → Booking + Payment
- **SD03**: Duyệt booking STAFF
- **SD04**: Thanh toán ZaloPay → Callback → Socket notify
- **SD05**: Tạo phòng ghép trận
- **SD06**: Join phòng ghép trận
- **SD07**: Fixed schedule generate booking (Cron)
- **SD08**: Gửi thông báo (Socket.IO + FCM)

---

# 5. THIẾT KẾ DỮ LIỆU VÀ ERD

> **File chi tiết**: [04_thiet_ke_du_lieu_erd.md](./04_thiet_ke_du_lieu_erd.md)

## Danh sách Models

| Model | Collection | Số fields chính | Quan hệ |
|-------|-----------|----------------|---------|
| User | users | 18+ | → Facility |
| Facility | facilities | 8 | ← User (staff_ids) |
| Sport | sports | 7 | ← Court |
| Court | courts | 10+ + SlotConfig | → Facility, → Sport |
| CourtBlock | courtblocks | 9 | → Facility, → Court |
| Booking | bookings | 15+ | → User, → Court, → FixedSchedule |
| Payment | payments | 15+ | → Booking, → User |
| Notification | notifications | 10 | → User |
| MatchingSession | matchingsessions | 20+ + members[] + teams[] | → User(host), → Sport, → Facility, → Court, → Booking |
| MatchQueue | matchqueues | 14 | → User, → Sport, → Facility |
| FixedSchedule | fixedschedules | 25+ + exception_dates[] + matching_config | → User, → Sport, → Facility, → Court |
| Review | reviews | 6 | → User, → Court |

## Ràng buộc nghiệp vụ quan trọng

1. Payment: Unique partial index `{ booking_id, user_id }` where `status in [PENDING, SUCCESS]`
2. Booking: Không trùng lịch cùng court+date+time range khi PENDING/CONFIRMED/COMPLETED
3. FixedSchedule Booking: Unique partial index cho booking từ lịch cố định
4. MatchingSession: Host chỉ có 1 session OPEN/FULL trong cùng slot thời gian
5. CourtBlock: `start_time < end_time` (pre-validate hook)
6. User: `email` unique, `firebaseUid` unique sparse

---

# 6. THIẾT KẾ API

> **File chi tiết**: [05_thiet_ke_api.md](./05_thiet_ke_api.md)

## Tổng quan API

**Base URL**: `/api/v1`  
**Auth**: Bearer JWT Token

| Nhóm | Số endpoints | Phương thức |
|------|-------------|------------|
| Auth | 13 | POST |
| User | 9 | GET, POST, PUT |
| Facility | 5 | GET, POST, PUT, DELETE |
| Sport | 4 | GET, POST, PUT, DELETE |
| Court | 6 | GET, POST, PUT, DELETE |
| Court Blocks | 3 | GET, POST, DELETE |
| Booking | 6 | GET, POST, PUT |
| Payment | 3 | GET, POST, PUT |
| ZaloPay | 3 | POST |
| Notification | 2 | GET, PUT |
| Matching | 11 | GET, POST, PUT |
| Fixed Schedule | 10 | GET, POST, PUT |
| Reports | 2 | GET |
| Review | 4 | GET, POST, PUT, DELETE |
| Upload | 1 | POST |
| Health | 4 | GET |

**Tổng**: ~86 endpoints

## API quan trọng

| Endpoint | Mô tả |
|----------|-------|
| `POST /auth/sign-in` | Đăng nhập, nhận JWT |
| `POST /booking` | Tạo booking |
| `PUT /booking/:id/status` | Duyệt/cập nhật booking |
| `PUT /booking/:id/cancel` | Hủy booking |
| `POST /matching` | Tạo phòng ghép trận |
| `POST /matching/:id/join` | Tham gia phòng |
| `POST /matching/queue/join` | Vào hàng đợi auto match |
| `POST /fixed-schedule` | Tạo lịch cố định |
| `PUT /fixed-schedule/:id/approve` | Duyệt lịch cố định |
| `POST /zalopay/create-order` | Tạo đơn ZaloPay |
| `GET /reports/advanced-performance` | Báo cáo ADMIN |
| `GET /health/cron` | Status cron jobs |

---

# 7. GIAO DIỆN NGƯỜI DÙNG

> **File chi tiết**: [06_giao_dien_nguoi_dung.md](./06_giao_dien_nguoi_dung.md)

## Flutter Mobile — Danh sách màn hình

**Nhóm Auth**: Đăng nhập, Đăng ký, Xác thực OTP, Quên mật khẩu (4 màn hình)

**Nhóm Dashboard**: Dashboard Customer, Dashboard Staff, Dashboard Admin, Giám sát booking, Kiểm duyệt user, Giám sát payment, Báo cáo sân Staff, Cấu hình slot, Cài đặt (13 màn hình)

**Nhóm Booking**: Đặt sân (court_booking_page 65KB), Danh sách booking, Chi tiết booking, Lịch sử booking (4 màn hình)

**Nhóm Payment**: Chi tiết hóa đơn (invoice_detail 83KB), ZaloPay WebView, Mock payment (3 màn hình)

**Nhóm Matching**: Tạo phòng (create_matching 85KB), Khám phá phòng, Chi tiết phòng, Hàng đợi auto (4 màn hình)

**Tổng**: ~28+ màn hình Flutter

## React Web Admin — Danh sách trang

**Auth**: Đăng nhập, Hồ sơ (2 trang)

**Dashboard/Report**: Tổng quan Admin, Tổng quan Staff, Báo cáo Staff (3 trang)

**Facility/Court/Sport**: Admin facilities, Admin courts, Admin sports, Staff courts, Staff slots, Staff sports (6 trang)

**Booking**: Admin supervision, Staff bookings, Chi tiết booking (3 trang)

**Payment**: Staff cashier (1 trang)

**Matching**: Danh sách, Chi tiết (2 trang)

**Fixed Schedule**: Danh sách, Chi tiết (2 trang)

**User Management**: Admin users (1 trang)

**Notifications**: Admin, Staff (2 trang)

**Reviews**: Danh sách, Chi tiết (2 trang)

**Tổng**: ~24 trang React Web Admin

---

# 8. NGHIỆP VỤ CHI TIẾT

> **File chi tiết**: [07_nghiep_vu_chi_tiet.md](./07_nghiep_vu_chi_tiet.md)

## Booking — Quy trình và trạng thái

```
PENDING → CONFIRMED (STAFF duyệt)
PENDING → CANCELLED (Hủy thủ công hoặc Cron auto-cancel)
CONFIRMED → CANCELLED (Hủy thủ công)
CONFIRMED → COMPLETED (Cron auto-complete sau giờ kết thúc)
```

**Kiểm tra conflict**: Booking overlap + Court Block overlap

**Tính giá**: `price_per_hour × (end_minutes - start_minutes) / 60`

## Fixed Schedule — Quy trình

```
PENDING_APPROVAL → ACTIVE (STAFF duyệt → sinh booking)
ACTIVE → PAUSED (Tạm dừng)
PAUSED → ACTIVE (Tiếp tục)
ACTIVE/PAUSED → CANCELLED (Hủy cả chuỗi)
ACTIVE → EXPIRED (Qua end_date)
```

**Cron fixedScheduler**: 00:05 hàng ngày + startup — sinh booking cho 14 ngày tới

## Matching — Quy trình

**Manual**: Host tạo session → Member join → Host approve (nếu manual) → FULL

**Auto Queue**:
1. User join queue với tiêu chí tìm kiếm
2. Cron matchmaker mỗi phút: tìm entries tương thích → tạo booking + session → notify

**Team modes**: INDIVIDUAL | TEAM_FILL | TEAM_VS_TEAM  
**Payment policies**: HOST_PAY_ALL | SPLIT_EQUALLY | TEAM_REPRESENTATIVES_SPLIT

## ZaloPay — Quy trình

```
Flutter → POST /zalopay/create-order → order_url
Flutter → Mở WebView với order_url
Customer thanh toán → ZaloPay server callback
Backend verify HMAC → Payment SUCCESS → notify
```

---

# 9. CRON JOB, SOCKET.IO VÀ NOTIFICATION

> **File chi tiết**: [08_cron_socket_notification.md](./08_cron_socket_notification.md)

## 4 Cron Jobs

| Cron | Lịch | Chức năng |
|------|------|-----------|
| autoCancelBookings | `*/1 * * * *` | Hủy PENDING booking quá hạn |
| autoCompleteBookings | `*/1 * * * *` | Hoàn thành booking đã qua giờ |
| matchmaker | `*/1 * * * *` | Ghép trận tự động + expire queue |
| fixedScheduler | `5 0 * * *` + startup | Sinh booking từ lịch cố định |

## Socket.IO Rooms và Events

| Room | Người nhận |
|------|-----------|
| `user_{id}` | 1 user cụ thể |
| `room_staff` | Tất cả STAFF online |
| `room_admin` | Tất cả ADMIN online |
| `room_matching_{id}` | Tất cả trong phòng ghép trận |

**Events emit**: `notification_received`, `new_notification`, `matching_session_updated`

## FCM Push Notification

- **Firebase Admin SDK** gửi qua `messaging.sendMulticast(tokens, message)`
- Flutter nhận qua `firebase_messaging` (foreground + background + terminated)
- Cần `serviceAccountKey.json` production để hoạt động đầy đủ

---

# 10. TRIỂN KHAI VÀ MÔI TRƯỜNG

> **File chi tiết**: [09_trien_khai_moi_truong.md](./09_trien_khai_moi_truong.md)

## Biến môi trường Backend (chỉ tên)

`PORT`, `MONGODB_URI`, `JWT_SECRET`, `JWT_REFRESH_SECRET`, `JWT_EXPIRES_IN`, `CLOUDINARY_*`, `FIREBASE_*`, `ZALOPAY_*`, `EMAIL_USER`, `EMAIL_PASSWORD`, `FRONTEND_URL`, `NODE_ENV`

## Build và Deploy

| Thành phần | Lệnh | Output |
|-----------|------|--------|
| Flutter Android | `flutter build apk --release` | APK |
| React Web | `npm run build` | Static files |
| Backend | `npm start` | Node.js process |

## Tình trạng deploy

| Thành phần | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Backend | ✅ Render.com | Cần UptimeRobot |
| MongoDB | ✅ Atlas M0 | Free tier 512MB |
| Cloudinary | ✅ Free tier | 25GB/tháng |
| ZaloPay | ⚠️ Sandbox | Cần merchant production |
| FCM | ⚠️ Cần config | Cần serviceAccountKey |
| Flutter APK | ⚠️ Local build | Chưa publish Play Store |

---

# 11. ĐÁNH GIÁ HIỆN TRẠNG

> **File chi tiết**: [10_danh_gia_hien_trang.md](./10_danh_gia_hien_trang.md)

## Tổng kết mức độ hoàn thiện

| Chức năng | Mức độ |
|-----------|--------|
| Tài khoản & Phân quyền | ✅ 95% |
| Quản lý Facility/Court/Sport | ✅ 95% |
| Booking (đặt, duyệt, hủy, auto) | ✅ 90% |
| Lịch cố định | ✅ 85% |
| Ghép trận Manual | ✅ 85% |
| Ghép trận Auto Queue | ✅ 75% |
| Thanh toán CASH | ✅ 90% |
| Thanh toán ZaloPay | ⚠️ 70% (Sandbox) |
| Thông báo Socket.IO | ✅ 90% |
| FCM Push | ⚠️ 60% (cần key) |
| Báo cáo | ✅ 85% |
| Web Admin | ✅ 90% |
| Review | ⚠️ 60% |

## So sánh với yêu cầu đề tài

✅ Hệ thống đáp ứng **đầy đủ** yêu cầu đề tài. Tính năng ghép trận tự động là **điểm nổi bật khác biệt**.

## Kiến nghị cải tiến ưu tiên

1. 🔴 Rate limiting API (bảo mật)
2. 🔴 ZaloPay production credentials
3. 🔴 MongoDB session transactions (toàn vẹn dữ liệu)
4. 🟡 serviceAccountKey FCM production
5. 🟡 Pagination chuẩn cho list API
6. 🟡 Refund flow tự động

---

# 12. NỘI DUNG VIẾT SẴN CHO BÁO CÁO

> **File chi tiết**: [11_noi_dung_viet_san.md](./11_noi_dung_viet_san.md)

File `11_noi_dung_viet_san.md` chứa đầy đủ các đoạn văn học thuật tiếng Việt để sử dụng trong báo cáo:

- **Phần 1**: Lý do chọn đề tài + Mục tiêu đề tài + Phạm vi và giới hạn
- **Phần 2**: Cơ sở lý thuyết (Node.js, MongoDB, Flutter, React, Socket.IO, Firebase, ZaloPay, JWT, BLoC)
- **Phần 3**: Phân tích và thiết kế hệ thống (mô tả bài toán, đặc tả chức năng, kiến trúc)
- **Phần 4**: Cài đặt và kiểm thử (môi trường, hướng dẫn, 5 kịch bản test case chi tiết)
- **Phần 5**: Kết luận (kết quả đạt được, hạn chế, hướng phát triển, lời kết)

---

## Thống kê dự án

| Thống kê | Số liệu |
|---------|---------|
| MongoDB schemas (Models) | 12 schemas |
| API Endpoints | ~86 endpoints |
| Cron Jobs | 4 jobs |
| Flutter màn hình | ~28+ screens |
| React Web trang | ~24 pages |
| Dịch vụ tích hợp | 6 (MongoDB, Cloudinary, Firebase, ZaloPay, Gmail, Socket.IO) |
| Tổng dòng code Backend services | ~250KB (ước tính) |
| File service lớn nhất | `fixed-schedule.service.js` (77KB) |
| File màn hình Flutter lớn nhất | `create_matching_session_page.dart` (85KB) |

---

*Hết file tổng hợp. Xem các file chi tiết theo số thứ tự 00-11 cho nội dung đầy đủ của từng phần.*
