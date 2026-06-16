# BỘ TÀI LIỆU TỔNG HỢP – REPORT EXPORT FULL
# Đề tài: Xây dựng Ứng dụng Android Quản lý Khu Liên hợp Thể thao Tích hợp Tính năng Tìm kiếm Đối thủ
# Ngày xuất: 2026-06-16

---

> **Lưu ý về bảo mật:**
> Tài liệu này KHÔNG chứa giá trị của bất kỳ biến môi trường, secret key, token, password, hay thông tin nhạy cảm nào.
> Các tên biến môi trường được liệt kê chỉ để mô tả mục đích, không hiển thị giá trị thực.

---

## MỤC LỤC TÀI LIỆU

| STT | File | Nội dung |
|-----|------|---------|
| 1 | `00_tong_quan_du_an.md` | Tên đề tài, mục tiêu, đối tượng, phạm vi, tính năng hoàn thiện/chưa hoàn thiện |
| 2 | `01_cong_nghe_kien_truc.md` | Công nghệ và thư viện, sơ đồ kiến trúc, cấu trúc thư mục Backend/Flutter/React |
| 3 | `02_phan_tich_yeu_cau.md` | Tác nhân, bảng yêu cầu chức năng chi tiết (8 nhóm), yêu cầu phi chức năng |
| 4 | `03_usecase_activity_sequence.md` | Use case tổng quát và chi tiết, mô tả Activity Diagram, Sequence Diagram |
| 5 | `04_thiet_ke_du_lieu_erd.md` | Chi tiết 12 Schema MongoDB, quan hệ dữ liệu, gợi ý vẽ ERD |
| 6 | `05_thiet_ke_api.md` | 50+ API endpoint, mô tả chi tiết 11 API quan trọng với request/response mẫu |
| 7 | `06_giao_dien_nguoi_dung.md` | Danh sách màn hình Flutter và React Web, mô tả giao diện |
| 8 | `07_nghiep_vu_chi_tiet.md` | Nghiệp vụ Đặt sân, Lịch cố định, Ghép trận, Thanh toán, Báo cáo |
| 9 | `08_cron_socket_notification.md` | Chi tiết 4 Cron Jobs, Socket.IO rooms và events, Notification helper, FCM |
| 10 | `09_kiem_thu_minh_chung.md` | 17 test case Postman, bảng test case nghiệp vụ, danh sách ảnh cần chụp |
| 11 | `10_danh_gia_hien_trang.md` | Bảng mức độ hoàn thiện, điểm mạnh, hạn chế, hướng phát triển |
| 12 | `11_noi_dung_viet_san_cho_bao_cao.md` | Các đoạn văn sẵn: tóm tắt, mở đầu, bối cảnh, yêu cầu, thiết kế, kết luận |
| 13 | `12_bien_moi_truong_cau_hinh.md` | Tên biến môi trường và mục đích, cấu hình deploy Render.com |

---

## PHẦN I: TỔNG QUAN DỰ ÁN

### 1.1 Tên hệ thống
**Sport Energy** – Hệ thống quản lý khu liên hợp thể thao tích hợp đặt sân, lịch cố định, ghép đối thủ và thanh toán điện tử.

*(Tên đề tài báo cáo: "Xây dựng ứng dụng Android quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ")*

### 1.2 Thành phần hệ thống

| Thành phần | Công nghệ | Phục vụ |
|-----------|----------|---------|
| Backend API | Node.js + Express + MongoDB | Cả Flutter và Web Admin |
| Mobile App | Flutter (Android) | CUSTOMER |
| Web Admin | React + TypeScript | ADMIN, STAFF |
| Real-time | Socket.IO | Cả Mobile và Web |
| Push Notification | Firebase FCM | Mobile (CUSTOMER) |
| Thanh toán | ZaloPay | Mobile (CUSTOMER) |
| Media | Cloudinary | Tất cả |
| Email | Nodemailer | Tất cả (OTP reset password) |

### 1.3 Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                            │
│  [Flutter Android] ←──→ [React Web Admin (SPA)]            │
│       (CUSTOMER)             (ADMIN + STAFF)                │
└──────────────┬──────────────────────────┬───────────────────┘
               │  HTTP REST + WebSocket   │
┌──────────────▼──────────────────────────▼───────────────────┐
│                    BACKEND LAYER                             │
│       Node.js/Express: REST API + Socket.IO + Cron(4)       │
└──────────────┬──────────────────────────────────────────────┘
               │
┌──────────────▼────────────┐ ┌──────────┐ ┌───────────────┐
│    MongoDB (Atlas)        │ │ Firebase │ │  Cloudinary   │
│  12 Collections + Indexes │ │   FCM    │ │ Media Storage │
└───────────────────────────┘ └──────────┘ └───────────────┘
                                    + ZaloPay + Nodemailer
```

### 1.4 Tóm tắt tính năng chính

| Tính năng | Mô tả ngắn | Công nghệ chính |
|-----------|------------|----------------|
| **Đặt sân** | Chọn sân, ngày, slot; kiểm tra xung đột tự động | Booking model, unique index |
| **Lịch cố định** | Đặt định kỳ, tự động sinh booking hàng ngày | Cron 00:05, FixedSchedule model |
| **Ghép trận** | Tìm đối thủ thủ công + tự động theo queue | Matching model, Cron 1 phút |
| **Thanh toán** | ZaloPay + tiền mặt, callback HMAC | ZaloPay SDK, webhook |
| **Thông báo** | Real-time (online) + Push (offline) | Socket.IO + Firebase FCM |
| **Báo cáo** | Hiệu suất sân, doanh thu theo thời gian | report.service.js, Recharts |

---

## PHẦN II: STACK CÔNG NGHỆ

### Backend Node.js/Express

| Package | Version | Mục đích |
|---------|---------|---------|
| express | ^4.19.2 | Web framework |
| mongoose | ^8.24.0 | MongoDB ODM |
| jsonwebtoken | ^9.0.3 | JWT Auth |
| bcrypt | ^6.0.0 | Password hashing |
| socket.io | ^4.7.2 | Real-time WebSocket |
| firebase-admin | ^13.10.0 | FCM push notification |
| node-cron | ^4.2.1 | Cron job scheduler |
| cloudinary | ^1.41.3 | Media upload |
| multer | ^2.1.1 | File upload middleware |
| nodemailer | ^8.0.10 | Email OTP |
| cors | ^2.8.5 | CORS middleware |
| dotenv | ^16.4.5 | ENV variables |

### Flutter/Dart

| Package | Version | Mục đích |
|---------|---------|---------|
| flutter_bloc | ^8.1.6 | State management |
| go_router | ^14.2.0 | Navigation |
| get_it | ^8.0.2 | Dependency Injection |
| dio | ^5.7.0 | HTTP Client |
| socket_io_client | ^2.0.3 | WebSocket |
| firebase_messaging | ^15.1.3 | FCM Push Notification |
| flutter_secure_storage | ^9.2.2 | Token storage |
| freezed | ^2.5.7 | Immutable models |
| dartz | ^0.10.1 | Functional Either |

### React Web Admin

| Package | Version | Mục đích |
|---------|---------|---------|
| antd | ^6.4.3 | UI Components |
| react-router-dom | ^7.15.1 | Routing |
| @tanstack/react-query | ^5.100.14 | Server state |
| axios | ^1.16.1 | HTTP Client |
| recharts | ^3.8.1 | Charts/Graphs |
| socket.io-client | ^4.7.5 | Real-time |
| tailwindcss | ^3.4.17 | CSS utility |
| typescript | ^4.9.5 | Type safety |

---

## PHẦN III: PHÂN TÍCH YÊU CẦU

### 3.1 Tác nhân hệ thống

| Tác nhân | Nền tảng | Chức năng chính |
|---------|---------|----------------|
| CUSTOMER | Flutter Android | Đặt sân, lịch cố định, ghép trận, thanh toán, thông báo |
| STAFF | Web Admin | Duyệt booking, thu ngân, quản lý vận hành, báo cáo |
| ADMIN | Web Admin | Toàn quyền + quản lý người dùng, cơ sở, báo cáo nâng cao |

### 3.2 Thống kê chức năng

| Nhóm chức năng | Số lượng | Trạng thái |
|---------------|---------|-----------|
| Tài khoản & phân quyền | 13 | ✅ Hoàn thành |
| Cơ sở, sân, môn thể thao | 17 | ✅ Hoàn thành (CourtBlock 1 phần) |
| Đặt sân | 9 | ✅ Hoàn thành |
| Lịch cố định | 11 | ⚠️ Một phần (Flutter chưa có trang tạo) |
| Ghép trận | 14 | ✅ Hoàn thành |
| Hóa đơn & Thanh toán | 8 | ⚠️ Một phần (refund chưa xong) |
| Thông báo | 6 | ✅ Hoàn thành |
| Báo cáo | 2 | ✅ Hoàn thành |
| **Tổng** | **80** | **~85% hoàn thành** |

---

## PHẦN IV: THIẾT KẾ DỮ LIỆU – TÓM TẮT

### 4.1 Danh sách Collection MongoDB

| Collection | Model | Mô tả |
|-----------|-------|-------|
| users | User | Tài khoản, role, FCM tokens |
| facilities | Facility | Cơ sở thể thao |
| sports | Sport | Môn thể thao |
| courts | Court | Sân + slot_config (embedded) |
| court-blocks | CourtBlock | Khóa/bảo trì sân |
| bookings | Booking | Đặt sân |
| payments | Payment | Hóa đơn |
| fixedschedules | FixedSchedule | Lịch cố định + exception_dates |
| matchingsessions | MatchingSession | Phiên ghép trận + members (embedded) |
| matchqueues | MatchQueue | Hàng đợi ghép tự động |
| notifications | Notification | Thông báo |
| reviews | Review | Đánh giá |

### 4.2 Ràng buộc unique index quan trọng

| Model | Unique Constraint | Mục đích |
|-------|-----------------|---------|
| User | `email` (unique) | Không trùng email |
| Booking | `{ court_id, booking_date, start/end_minutes }` partial (status active) | Chống đặt sân trùng lịch |
| FixedSchedule booking | `{ fixed_schedule_id, court_id, booking_date, start/end }` | Chống sinh booking trùng |
| MatchingSession | `{ host_id, booking_date, start/end }` partial (status open/full) | Host không tạo 2 session cùng giờ |
| Payment | `{ booking_id, user_id }` partial (status pending/success) | Mỗi booking 1 payment active |

---

## PHẦN V: API – TÓM TẮT

### 5.1 Tổng số API Endpoints

| Nhóm | Số Endpoint |
|------|------------|
| Auth | 7 |
| User | 8 |
| Facility | 5 |
| Sport | 4 |
| Court | 6 |
| Court Block | 4 |
| Booking | 5 |
| Payment | 3 |
| ZaloPay | 3 |
| Fixed Schedule | 11 |
| Matching | 10 |
| Notification | 4 |
| Reports | 2 |
| Review, Upload, Health | ~5 |
| **Tổng** | **~77** |

### 5.2 Response Format chuẩn

```json
{
  "success": true | false,
  "message": "Mô tả kết quả",
  "data": { ... },
  "code": "ERROR_CODE (chỉ khi lỗi)"
}
```

---

## PHẦN VI: CRON JOBS VÀ REAL-TIME

### 6.1 Cron Jobs

| Cron | Lịch | Chức năng | File |
|------|------|-----------|------|
| Auto Cancel Bookings | `*/1 * * * *` | Hủy booking PENDING quá hạn | `cron-auto-cancel-bookings.js` |
| Auto Complete Bookings | `*/1 * * * *` | Complete booking CONFIRMED hết giờ | `cron-auto-complete-bookings.js` |
| Auto Matchmaker | `*/1 * * * *` | Ghép queue entry tương thích | `cron-matchmaker.js` |
| Fixed Scheduler | `5 0 * * *` + startup | Sinh booking từ lịch cố định | `cron-fixed-scheduler.js` |

### 6.2 Socket.IO Rooms

| Room | Thành viên | Sự kiện nhận |
|------|-----------|-------------|
| `user_{userId}` | User cá nhân | `notification_received`, `new_notification` |
| `room_staff` | STAFF online | `notification_received`, `new_notification` |
| `room_admin` | ADMIN online | `notification_received`, `new_notification` |
| `room_matching_{id}` | Members trong session | `matching_session_updated` |

### 6.3 Notification Flow

```
Sự kiện nghiệp vụ (booking, payment, matching...)
    ↓
notification.helper.js
    ├──→ Lưu vào MongoDB (notifications collection)
    ├──→ Socket.IO (notifyUser / notifyStaff / notifyAdmin)
    │        ↓
    │    Flutter/Web nhận real-time nếu online
    └──→ FCM (fcm.service.js)
             ↓
         Firebase Admin SDK → Push notification (offline)
```

---

## PHẦN VII: GIAO DIỆN

### 7.1 Tổng số màn hình

| Nền tảng | Số màn hình | Ghi chú |
|---------|------------|---------|
| Flutter Android | ~18 màn hình | Splash, Auth, Home, Booking, Matching, Payment, Notification, Profile, Facility, Review |
| React Web Admin | ~25+ trang | Auth, Dashboard, Booking, Facility, Matching, FixedSchedule, Payment, Report, User, Review, Notification, Profile |

### 7.2 Giao diện nổi bật

- **CourtBookingPage (Flutter):** ~65KB – Màn hình đặt sân phức tạp với lưới slot giờ, chọn sân, tính giá
- **CreateMatchingSessionPage (Flutter):** ~85KB – Màn hình tạo phiên ghép trận với nhiều option
- **AdminOverviewPage (React):** Dashboard với biểu đồ Recharts, báo cáo nâng cao
- **StaffCashierPage (React):** Thu ngân, tra cứu hóa đơn, xác nhận thanh toán
- **FixedScheduleDetailPage (React):** Duyệt lịch cố định, xem exception, xem booking đã sinh

---

## PHẦN VIII: ĐIỂM MẠNH VÀ HẠN CHẾ

### 8.1 Điểm mạnh
1. ✅ Kiểm tra xung đột lịch đặt sân (unique index + overlap check)
2. ✅ Ghép trận đa chế độ (3 team modes + 3 payment policies)
3. ✅ Cron Jobs tự động hóa 4 tác vụ nền
4. ✅ Lịch cố định với cơ chế self-healing
5. ✅ ZaloPay tích hợp thật với HMAC callback
6. ✅ Real-time Socket.IO + Push FCM song song
7. ✅ Clean Architecture (Flutter, Node.js, React)
8. ✅ BLoC pattern + DI (Flutter), React Query (Web)
9. ✅ Phân quyền RBAC (verifyToken + requireRole)
10. ✅ Deploy thành công lên Render.com + MongoDB Atlas

### 8.2 Hạn chế
1. ⚠️ Hoàn tiền tự động chưa triển khai
2. ⚠️ MOMO/VNPay chưa có logic (chỉ có trong enum)
3. ⚠️ SUPER_ADMIN khai báo trong route nhưng không có trong model
4. ⚠️ Flutter chưa có màn hình tạo lịch cố định
5. ⚠️ Court Block chưa có trang quản lý trên Web Admin
6. ⚠️ Cron phụ thuộc server không sleep (Render Free Tier)
7. ⚠️ Chưa có unit test / integration test
8. ⚠️ iOS chưa được kiểm thử
9. ⚠️ Logging chưa chuyên nghiệp (chỉ console.log)

---

## PHẦN IX: BIẾN MÔI TRƯỜNG (Tên – Không có Giá trị)

### Backend (.env)
| Biến | Mục đích |
|------|---------|
| `PORT` | Cổng server |
| `MONGODB_URI` | Connection string MongoDB Atlas |
| `JWT_SECRET` | Ký Access Token |
| `JWT_REFRESH_SECRET` | Ký Refresh Token |
| `JWT_EXPIRES_IN` | TTL Access Token |
| `JWT_REFRESH_EXPIRES_IN` | TTL Refresh Token |
| `CLOUDINARY_CLOUD_NAME` | Tên Cloudinary Cloud |
| `CLOUDINARY_API_KEY` | Cloudinary API Key |
| `CLOUDINARY_API_SECRET` | Cloudinary API Secret |
| `EMAIL_USER` | Email gửi OTP |
| `EMAIL_PASS` | App Password email |
| `ZALOPAY_APP_ID` | ZaloPay App ID |
| `ZALOPAY_KEY1` | ZaloPay HMAC Key1 |
| `ZALOPAY_KEY2` | ZaloPay Callback Key2 |
| `ZALOPAY_ENDPOINT` | ZaloPay API URL |
| `ZALOPAY_CALLBACK_URL` | Webhook callback URL |
| `NODE_ENV` | development / production |

### Firebase Admin SDK
- File: `src/config/serviceAccountKey.json` (KHÔNG commit lên git)
- Tải từ Firebase Console → Project Settings → Service Accounts

---

## PHẦN X: HƯỚNG DẪN VIẾT BÁO CÁO

### Cấu trúc báo cáo đề xuất

| Chương | Tiêu đề | Nguồn tài liệu |
|--------|---------|---------------|
| **Chương 1** | Tổng quan đề tài | `11_noi_dung_viet_san.md` – Mục 12.1 → 12.7 |
| **Chương 2** | Cơ sở lý thuyết | `11_noi_dung_viet_san.md` – Mục 12.8 + `01_cong_nghe_kien_truc.md` |
| **Chương 3** | Phân tích và thiết kế hệ thống | `02_phan_tich_yeu_cau.md`, `03_usecase_activity_sequence.md`, `04_thiet_ke_du_lieu_erd.md`, `05_thiet_ke_api.md` |
| **Chương 4** | Xây dựng hệ thống | `01_cong_nghe_kien_truc.md` (cấu trúc thư mục), `07_nghiep_vu_chi_tiet.md`, `08_cron_socket_notification.md` |
| **Chương 5** | Giao diện người dùng | `06_giao_dien_nguoi_dung.md` + ảnh chụp thực tế |
| **Chương 6** | Kiểm thử | `09_kiem_thu_minh_chung.md` + ảnh Postman |
| **Chương 7** | Kết luận và hướng phát triển | `10_danh_gia_hien_trang.md`, `11_noi_dung_viet_san.md` – Mục 12.18, 12.19 |

### Checklist trước khi nộp báo cáo

- [ ] Vẽ đầy đủ Use Case Diagram (tổng quát + 2-3 chi tiết)
- [ ] Vẽ Activity Diagram cho Đặt sân, Ghép trận, Lịch cố định
- [ ] Vẽ Sequence Diagram cho Đăng nhập, Đặt sân, Thông báo
- [ ] Vẽ ERD đầy đủ 12 entity với foreign keys
- [ ] Vẽ sơ đồ kiến trúc hệ thống
- [ ] Chụp ảnh Postman cho 17 test case
- [ ] Chụp ảnh giao diện Flutter (~18 màn hình)
- [ ] Chụp ảnh giao diện Web Admin (~15 trang quan trọng)
- [ ] Điền kết quả "Pass/Fail" vào bảng test case nghiệp vụ
- [ ] Cập nhật URL deploy thực tế vào báo cáo
- [ ] Kiểm tra không có thông tin nhạy cảm trong báo cáo

---

## INDEX TÌM KIẾM NHANH

| Từ khóa tìm kiếm | Tìm ở đâu |
|-----------------|---------|
| Kiến trúc hệ thống | `01_cong_nghe_kien_truc.md` mục 2.2 |
| Danh sách thư viện Flutter | `01_cong_nghe_kien_truc.md` mục 2.1 |
| Use Case chi tiết UC09 (Đặt sân) | `03_usecase_activity_sequence.md` |
| ERD / Quan hệ dữ liệu | `04_thiet_ke_du_lieu_erd.md` |
| API Booking | `05_thiet_ke_api.md` |
| Cron Job Fixed Scheduler | `08_cron_socket_notification.md` mục 9.1 |
| Socket.IO Events | `08_cron_socket_notification.md` mục 9.2 |
| FCM Push | `08_cron_socket_notification.md` mục 9.3 |
| Bảng test case | `09_kiem_thu_minh_chung.md` |
| Danh sách ảnh cần chụp | `09_kiem_thu_minh_chung.md` mục 10.3 |
| Đoạn văn sẵn mở đầu | `11_noi_dung_viet_san_cho_bao_cao.md` mục 12.2 |
| Kết luận đề tài | `11_noi_dung_viet_san_cho_bao_cao.md` mục 12.18 |
| Biến môi trường | `12_bien_moi_truong_cau_hinh.md` |
| Deploy Render | `12_bien_moi_truong_cau_hinh.md` mục 13.4, 13.5 |
