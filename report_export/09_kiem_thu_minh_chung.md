# 9. KIỂM THỬ VÀ MINH CHỨNG

## 10.1 Các API nên test bằng Postman

### Setup Postman:
1. Base URL: `https://<your-backend>.onrender.com/api/v1` (hoặc `http://localhost:3000/api/v1` khi dev)
2. Tạo Environment variables: `{{base_url}}`, `{{customer_token}}`, `{{staff_token}}`, `{{admin_token}}`
3. Đặt header mặc định: `Content-Type: application/json`
4. Sau khi login, copy `accessToken` vào biến môi trường tương ứng

---

### TC-001: Đăng nhập CUSTOMER

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/auth/sign-in` |
| **Role/Token** | Không cần |
| **Request Body** | `{ "email": "customer@gmail.com", "password": "123456" }` |
| **Kết quả mong đợi** | HTTP 200, `data.accessToken` không null, `data.user.role = "CUSTOMER"` |
| **Dữ liệu cần chuẩn bị** | Tài khoản CUSTOMER đã tạo trong DB |

---

### TC-002: Đăng nhập STAFF

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/auth/sign-in` |
| **Request Body** | `{ "email": "staff.test02@gmail.com", "password": "..." }` |
| **Kết quả mong đợi** | HTTP 200, `data.user.role = "STAFF"` |

---

### TC-003: Đăng nhập ADMIN

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/auth/sign-in` |
| **Request Body** | `{ "email": "admin.system@gmail.com", "password": "..." }` |
| **Kết quả mong đợi** | HTTP 200, `data.user.role = "ADMIN"` |

---

### TC-004: Tạo Booking

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/booking` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | ```json { "court_id": "<court_id>", "booking_date": "2026-06-25", "start_minutes": 480, "end_minutes": 600 }``` |
| **Kết quả mong đợi** | HTTP 201, `data.booking.status = "PENDING"`, `data.payment.status = "PENDING"` |
| **Dữ liệu cần chuẩn bị** | Court tồn tại, slot giờ chưa bị đặt |

---

### TC-005: Tạo Booking trùng lịch (test conflict)

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/booking` |
| **Request Body** | Cùng court_id, booking_date, start/end_minutes với TC-004 |
| **Kết quả mong đợi** | HTTP 409 CONFLICT, `success: false` |

---

### TC-006: Duyệt Booking (STAFF)

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `PUT {{base_url}}/booking/<booking_id>/status` |
| **Auth** | `Bearer {{staff_token}}` |
| **Request Body** | `{ "status": "CONFIRMED" }` |
| **Kết quả mong đợi** | HTTP 200, `data.status = "CONFIRMED"` |

---

### TC-007: Hủy Booking (CUSTOMER)

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `PUT {{base_url}}/booking/<booking_id>/cancel` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | `{ "cancel_reason": "Bận đột xuất" }` |
| **Kết quả mong đợi** | HTTP 200, `data.status = "CANCELLED"` |

---

### TC-008: Tạo Payment

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/payment` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | `{ "booking_id": "<booking_id>", "method": "CASH" }` |
| **Kết quả mong đợi** | HTTP 201, `data.status = "PENDING"` |

---

### TC-009: STAFF xác nhận thu tiền mặt

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `PUT {{base_url}}/payment/<payment_id>/status` |
| **Auth** | `Bearer {{staff_token}}` |
| **Request Body** | `{ "status": "SUCCESS" }` |
| **Kết quả mong đợi** | HTTP 200, `data.status = "SUCCESS"` |

---

### TC-010: Tạo phiên ghép trận

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/matching` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | ```json { "sport_id": "<sport_id>", "facility_id": "<facility_id>", "court_id": "<court_id>", "booking_date": "2026-06-25", "start_minutes": 480, "end_minutes": 600, "total_players_needed": 4, "team_mode": "INDIVIDUAL", "auto_approve": true, "payment_policy": "SPLIT_EQUALLY" }``` |
| **Kết quả mong đợi** | HTTP 201, `data.status = "OPEN"` |

---

### TC-011: Tham gia phiên ghép trận

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/matching/<session_id>/join` |
| **Auth** | `Bearer {{customer_token2}}` (user khác) |
| **Request Body** | `{ "team_code": "A", "note": "Tôi muốn tham gia" }` |
| **Kết quả mong đợi** | HTTP 200, member xuất hiện trong `data.members` với status APPROVED (nếu auto_approve = true) |

---

### TC-012: Vào hàng đợi ghép tự động

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/matching/queue/join` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | ```json { "sport_id": "<sport_id>", "facility_id": "<facility_id>", "booking_date": "2026-06-25", "start_minutes": 480, "end_minutes": 600, "group_size": 4, "team_mode": "INDIVIDUAL", "payment_policy": "SPLIT_EQUALLY" }``` |
| **Kết quả mong đợi** | HTTP 201, `data.status = "SEARCHING"` |

---

### TC-013: Tạo lịch cố định

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/fixed-schedule` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | ```json { "type": "COURT_BOOKING", "sport_id": "<sport_id>", "facility_id": "<facility_id>", "court_id": "<court_id>", "start_minutes": 480, "end_minutes": 600, "frequency": "WEEKLY", "days_of_week": [1, 3, 5], "start_date": "2026-06-23" }``` |
| **Kết quả mong đợi** | HTTP 201, `data.status = "PENDING_APPROVAL"` |

---

### TC-014: Duyệt lịch cố định (ADMIN/STAFF)

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `PUT {{base_url}}/fixed-schedule/<id>/approve` |
| **Auth** | `Bearer {{admin_token}}` hoặc `{{staff_token}}` |
| **Kết quả mong đợi** | HTTP 200, `data.status = "ACTIVE"`, booking cho 7 ngày tới được sinh |

---

### TC-015: Hủy một buổi lịch cố định

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `POST {{base_url}}/fixed-schedule/<id>/occurrences/2026-06-25/cancel` |
| **Auth** | `Bearer {{customer_token}}` |
| **Request Body** | `{ "reason": "Bận việc" }` |
| **Kết quả mong đợi** | HTTP 200, `data.exception_dates` có entry ngày 2026-06-25 |

---

### TC-016: Xem báo cáo hiệu suất sân

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `GET {{base_url}}/reports/court-performance?facility_id=<id>&from=2026-06-01&to=2026-06-30` |
| **Auth** | `Bearer {{staff_token}}` |
| **Kết quả mong đợi** | HTTP 200, `data.courts` có danh sách với `total_bookings`, `total_revenue` |

---

### TC-017: Health Check

| Trường | Giá trị |
|--------|---------|
| **Method + Endpoint** | `GET <base_url_without_api_v1>/health` |
| **Auth** | Không cần |
| **Kết quả mong đợi** | HTTP 200, `{ status: "ok", uptime: <number> }` |

---

## 10.2 Test case nghiệp vụ

| Mã | Chức năng | Điều kiện đầu vào | Các bước | Kết quả mong đợi | Kết quả thực tế | Pass/Fail |
|----|-----------|------------------|----------|-----------------|----------------|-----------|
| BTC-01 | Đặt sân thành công | Slot trống, court ACTIVE, user đã đăng nhập | 1. Login → 2. Chọn sân, slot → 3. Xác nhận đặt | Booking PENDING, Payment PENDING được tạo | *(Điền sau khi test)* | *(Điền)* |
| BTC-02 | Đặt sân trùng lịch | Slot đã có booking CONFIRMED | 1. Login → 2. Chọn slot đã đặt → 3. Xác nhận | Lỗi 409 CONFLICT | *(Điền)* | *(Điền)* |
| BTC-03 | Đặt sân - Court MAINTENANCE | Court status MAINTENANCE | 1. Login → 2. Chọn sân đang bảo trì | Lỗi 400 BAD_REQUEST | *(Điền)* | *(Điền)* |
| BTC-04 | Hủy booking hợp lệ | Booking PENDING của chính user | 1. Login CUSTOMER → 2. Xem lịch sử → 3. Hủy | Booking CANCELLED, thông báo gửi đi | *(Điền)* | *(Điền)* |
| BTC-05 | Hủy booking của người khác | Booking của user A, login user B | 1. Login user B → 2. Gọi cancel booking của A | Lỗi 403 FORBIDDEN | *(Điền)* | *(Điền)* |
| BTC-06 | Duyệt booking (STAFF) | Booking PENDING | 1. Login STAFF → 2. Xem danh sách → 3. Duyệt | Booking CONFIRMED, thông báo cho CUSTOMER | *(Điền)* | *(Điền)* |
| BTC-07 | Thanh toán tiền mặt (STAFF) | Payment PENDING | 1. Login STAFF → 2. Cashier → 3. Xác nhận thu | Payment SUCCESS, booking CONFIRMED | *(Điền)* | *(Điền)* |
| BTC-08 | Tạo phiên ghép trận | Có booking hoặc không | 1. Login CUSTOMER → 2. Điền form → 3. Tạo | Session OPEN, host là member A | *(Điền)* | *(Điền)* |
| BTC-09 | Join phiên ghép trận (auto_approve) | Session OPEN, auto_approve=true | 1. Login user khác → 2. Join session | Member APPROVED ngay lập tức | *(Điền)* | *(Điền)* |
| BTC-10 | Phiên ghép trận đủ người → FULL | Join đủ total_players_needed | Các user join đến khi đủ số lượng | Session FULL | *(Điền)* | *(Điền)* |
| BTC-11 | Ghép tự động | 2+ user vào queue cùng sport/facility/giờ | 1. User A join queue → 2. User B join queue → 3. Chờ cron | Queue MATCHED, session OPEN được tạo | *(Điền)* | *(Điền)* |
| BTC-12 | Tạo lịch cố định | Đăng ký lịch WEEKLY | Điền form, submit | FixedSchedule PENDING_APPROVAL | *(Điền)* | *(Điền)* |
| BTC-13 | Duyệt lịch cố định → sinh booking | Lịch PENDING_APPROVAL | Login ADMIN → Approve | Status ACTIVE, booking 7 ngày tới được sinh | *(Điền)* | *(Điền)* |
| BTC-14 | Hủy một buổi lịch cố định | FixedSchedule ACTIVE | Chọn ngày → Cancel occurrence | exception_dates có entry ngày đó | *(Điền)* | *(Điền)* |
| BTC-15 | Auto cancel booking quá hạn | Booking PENDING đã quá giờ | Chờ cron chạy (1 phút) | Booking CANCELLED tự động | *(Điền)* | *(Điền)* |
| BTC-16 | Thông báo real-time | User online, tạo booking | 1. User B đang online → 2. STAFF tạo booking cho cơ sở | STAFF nhận thông báo qua Socket.IO | *(Điền)* | *(Điền)* |

---

## 10.3 Danh sách ảnh nên chụp đưa vào báo cáo

### Sơ đồ cần vẽ (tự vẽ bằng công cụ như draw.io, Lucidchart)
- [ ] `sodo_kien_truc_he_thong.png` – Sơ đồ kiến trúc tổng thể (client-server)
- [ ] `sodo_usecase_tong_quat.png` – Use case diagram tổng quát
- [ ] `sodo_usecase_datsan.png` – Use case đặt sân chi tiết
- [ ] `sodo_activity_datsan.png` – Activity diagram đặt sân
- [ ] `sodo_activity_gheptran.png` – Activity diagram ghép trận
- [ ] `sodo_activity_lichcodinh.png` – Activity diagram lịch cố định
- [ ] `sodo_sequence_dangnhap.png` – Sequence diagram đăng nhập
- [ ] `sodo_sequence_datsan.png` – Sequence diagram đặt sân
- [ ] `sodo_sequence_gheptran.png` – Sequence diagram ghép trận
- [ ] `sodo_sequence_thongbao.png` – Sequence diagram gửi thông báo
- [ ] `sodo_erd.png` – ERD diagram đầy đủ
- [ ] `cautructhumuc_backend.png` – Cấu trúc thư mục backend
- [ ] `cautructhumuc_flutter.png` – Cấu trúc thư mục Flutter
- [ ] `cautructhumuc_react.png` – Cấu trúc thư mục React

### Ảnh Postman
- [ ] `postman_login.png` – Kết quả đăng nhập
- [ ] `postman_create_booking.png` – Tạo booking thành công
- [ ] `postman_conflict_booking.png` – Lỗi trùng lịch
- [ ] `postman_cancel_booking.png` – Hủy booking
- [ ] `postman_approve_booking.png` – Duyệt booking
- [ ] `postman_create_payment.png` – Tạo payment
- [ ] `postman_cashier_confirm.png` – Thu ngân xác nhận
- [ ] `postman_create_matching.png` – Tạo phiên ghép trận
- [ ] `postman_join_matching.png` – Tham gia phiên
- [ ] `postman_queue_join.png` – Vào hàng đợi tự động
- [ ] `postman_create_fixed_schedule.png` – Tạo lịch cố định
- [ ] `postman_approve_fixed_schedule.png` – Duyệt lịch
- [ ] `postman_report_court.png` – Báo cáo hiệu suất sân
- [ ] `postman_health_check.png` – Health check

### Ảnh giao diện Flutter Mobile
- [ ] `flutter_splash.png` – Splash screen
- [ ] `flutter_dangnhap.png` – Đăng nhập
- [ ] `flutter_dangky.png` – Đăng ký
- [ ] `flutter_home.png` – Màn hình chính
- [ ] `flutter_danhsachcoso.png` – Danh sách cơ sở
- [ ] `flutter_datsan.png` – Màn hình đặt sân (chọn slot)
- [ ] `flutter_xacnhandat.png` – Xác nhận đặt sân
- [ ] `flutter_lichsudat.png` – Lịch sử đặt sân
- [ ] `flutter_chitietbooking.png` – Chi tiết booking
- [ ] `flutter_hoadon.png` – Danh sách hóa đơn
- [ ] `flutter_thanhtoan_zalopay.png` – Màn hình ZaloPay
- [ ] `flutter_gheptran_explorer.png` – Tìm phiên ghép trận
- [ ] `flutter_gheptran_detail.png` – Chi tiết phiên
- [ ] `flutter_taogheptran.png` – Tạo phiên ghép trận
- [ ] `flutter_autolobby.png` – Lobby ghép tự động
- [ ] `flutter_thongbao.png` – Danh sách thông báo
- [ ] `flutter_hoso.png` – Hồ sơ cá nhân

### Ảnh giao diện Web Admin
- [ ] `web_dangnhap.png` – Đăng nhập portal
- [ ] `web_dashboard_admin.png` – Dashboard Admin
- [ ] `web_dashboard_staff.png` – Tổng quan Staff
- [ ] `web_qlbooking_staff.png` – Quản lý booking (Staff)
- [ ] `web_chitiet_booking.png` – Chi tiết booking
- [ ] `web_cashier.png` – Thu ngân
- [ ] `web_lichcodinh_list.png` – Danh sách lịch cố định
- [ ] `web_lichcodinh_detail.png` – Chi tiết lịch cố định (duyệt)
- [ ] `web_matching_list.png` – Danh sách phiên ghép trận
- [ ] `web_matching_detail.png` – Chi tiết phiên ghép trận
- [ ] `web_qlcoso.png` – Quản lý cơ sở
- [ ] `web_qlsan.png` – Quản lý sân
- [ ] `web_slot.png` – Quản lý slot giờ
- [ ] `web_qluser.png` – Quản lý người dùng
- [ ] `web_baocao_staff.png` – Báo cáo Staff
- [ ] `web_thongbao.png` – Trang thông báo
- [ ] `web_danhgia.png` – Quản lý đánh giá
