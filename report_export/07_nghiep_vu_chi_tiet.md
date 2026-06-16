# 8. NGHIỆP VỤ CHI TIẾT

## 8.1 Nghiệp vụ Đặt sân

### Điều kiện để tạo booking thành công:
1. **User đã đăng nhập** (JWT hợp lệ)
2. **Court tồn tại và có status ACTIVE** – kiểm tra trong MongoDB
3. **Không có CourtBlock trong khung giờ** – `court-block.service.js` kiểm tra
4. **Không có booking trùng lịch** – `court-availability.service.js` kiểm tra:
   - Query booking cùng `court_id`, `booking_date`, các booking có status PENDING hoặc CONFIRMED
   - Kiểm tra overlap: `start_minutes < existing.end_minutes AND end_minutes > existing.start_minutes`
5. **Slot hợp lệ** – trong phạm vi `opening_minutes` đến `closing_minutes` của Court

### Tính giá:
- `total_price = price_per_hour × (end_minutes - start_minutes) / 60`
- File: `booking-price.service.js`

### Trạng thái booking (vòng đời):
```
PENDING → CONFIRMED → COMPLETED
                ↘ CANCELLED (bởi user hoặc STAFF/ADMIN hoặc hệ thống)
PENDING → CANCELLED (auto-cancel nếu quá hạn)
```

### Khi nào được hủy:
- CUSTOMER chỉ hủy booking của chính mình, trạng thái PENDING hoặc CONFIRMED
- STAFF/ADMIN hủy bất kỳ booking nào ở trạng thái PENDING hoặc CONFIRMED
- Booking COMPLETED không thể hủy

### Auto Cancel (Cron job `cron-auto-cancel-bookings.js`):
- Chạy mỗi **1 phút** (`*/1 * * * *`)
- Tự động hủy booking PENDING mà đã quá giờ bắt đầu mà chưa được xác nhận
- Gọi `bookingService.autoCancelPendingBookings()`

### Auto Complete (Cron job `cron-auto-complete-bookings.js`):
- Chạy mỗi **1 phút** (`*/1 * * * *`)
- Tự động chuyển booking CONFIRMED → COMPLETED khi đã qua giờ kết thúc

### Thông báo liên quan:
- Tạo booking → Notify STAFF của cơ sở
- STAFF xác nhận → Notify CUSTOMER
- STAFF/ADMIN hủy → Notify CUSTOMER
- Auto cancel → Notify CUSTOMER

### Payment liên quan:
- Khi tạo booking → tự động tạo Payment với status PENDING
- Khi booking bị hủy → Payment có thể chuyển CANCELLED hoặc xử lý hoàn tiền

---

## 8.2 Nghiệp vụ Lịch cố định

### Tạo lịch cố định:
- CUSTOMER gửi request với: loại (COURT_BOOKING hoặc MATCHING), sân, cơ sở, môn thể thao, giờ bắt đầu/kết thúc, tần suất (DAILY hoặc WEEKLY), ngày trong tuần (nếu WEEKLY), ngày bắt đầu
- Hệ thống tạo FixedSchedule với status `PENDING_APPROVAL`
- Gửi thông báo đến STAFF/ADMIN của cơ sở để xét duyệt

### Duyệt lịch cố định:
- ADMIN/STAFF xem danh sách PENDING_APPROVAL trên Web Admin
- Click Duyệt → status → `ACTIVE`, ghi `approved_by`, `approved_at`
- **Ngay lập tức** sinh booking cho 7 ngày tới (gọi `generateBookingsForRange`)
- Từ chối → status → `REJECTED`, ghi lý do, gửi thông báo cho CUSTOMER

### Sinh booking tự động (Cron `cron-fixed-scheduler.js`):
- Chạy vào **00:05 hàng ngày** (`5 0 * * *`)
- Khi khởi động server cũng chạy ngay sau 5 giây (self-healing)
- Quét toàn bộ FixedSchedule có status `ACTIVE`
- Với mỗi lịch: sinh booking cho range `hôm nay đến 7 ngày tới`
- Bỏ qua các ngày nằm trong `exception_dates`
- Bỏ qua ngày không thuộc `days_of_week` (nếu WEEKLY)
- Không tạo booking trùng (kiểm tra unique index)
- Nếu sân bị conflict → bỏ qua hoặc xử lý theo cấu hình

### Tạm dừng / Tiếp tục:
- `ACTIVE → PAUSED`: ghi `paused_at`, không sinh booking mới
- `PAUSED → ACTIVE`: xóa `paused_at`, sinh booking lại từ hôm nay

### Hủy một buổi (Exception Date):
- Thêm một entry vào `exception_dates` với `date` và `type: CANCELLED`
- Cron job sẽ bỏ qua ngày này khi sinh booking

### Hủy cả chuỗi:
- Status → `CANCELLED`
- Các booking đã sinh cho tương lai có thể bị hủy (tùy theo logic trong service)

### Payment trong lịch cố định:
- Mỗi booking sinh ra từ lịch cố định cũng có Payment PENDING riêng
- CUSTOMER hoặc STAFF thanh toán từng buổi riêng lẻ

---

## 8.3 Nghiệp vụ Ghép trận

### Ghép thủ công (Manual Matching):
1. **Host tạo Session:** Có booking xác nhận → tạo MatchingSession liên kết booking đó. Hoặc tạo session độc lập (host tự tìm sân sau)
2. **Session OPEN:** Host là member đầu tiên, team_code = A (mặc định)
3. **User join:** Gọi `POST /matching/:id/join`. Nếu `auto_approve = true` → APPROVED ngay. Nếu `false` → PENDING chờ host duyệt
4. **Host duyệt:** `PUT /matching/:id/members/:userId` với `{ status: 'APPROVED' | 'REJECTED' }`
5. **Session FULL:** Khi số APPROVED members đủ `total_players_needed` → status tự động → FULL
6. **User leave:** `POST /matching/:id/leave` → xóa member, session có thể trở lại OPEN nếu chưa đủ

### Chế độ đội (team_mode):
- `INDIVIDUAL`: Chơi cá nhân, không phân đội
- `TEAM_FILL`: Một đội đầy đủ tìm thêm thành viên
- `TEAM_VS_TEAM`: Hai đội đấu nhau (teams[A] và teams[B])

### TEAM_REPRESENTATIVE:
- Một người tham gia `join_mode: TEAM_REPRESENTATIVE` đại diện cho nhiều người (`represented_count > 1`)
- Tính vào `total_players_needed` theo `represented_count`

### Ghép tự động (Auto Matching):
1. User join MatchQueue với thông tin: sport, facility, ngày, giờ, group_size, team_mode
2. Cron job chạy mỗi **1 phút** gọi `matchingService.runMatchmakerAlgorithm(sport, facility, date)`
3. Thuật toán nhóm các queue entry có thông tin tương thích
4. Nếu đủ `group_size` → Tạo MatchingSession, phân công thành viên
5. Cập nhật queue entries → MATCHED, liên kết `matching_session_id`
6. Gửi thông báo đến tất cả thành viên
7. `autoCancelUnmatched()`: Hủy các session OPEN không còn người join, expire các queue entry cũ

### Chính sách thanh toán (payment_policy):
- `HOST_PAY_ALL`: Host chịu toàn bộ chi phí sân
- `SPLIT_EQUALLY`: Chia đều cho tất cả thành viên APPROVED
- `TEAM_REPRESENTATIVES_SPLIT`: Đại diện đội (representative) trả cho đội mình

### Socket.IO real-time trong Matching:
- Host tạo session → app Flutter join `room_matching_{sessionId}`
- Khi có member join/leave/approved → `notifyMatchingUpdate` → emit `matching_session_updated` đến toàn phòng
- Tất cả người trong phòng nhận cập nhật real-time mà không cần reload

---

## 8.4 Nghiệp vụ Thanh toán / Hóa đơn

### Payment được tạo khi nào:
- **Ngay khi tạo Booking:** `booking.service.js` tự động gọi `createPayment` sau khi lưu booking
- Payment mặc định: `method: CASH`, `status: PENDING`

### Vòng đời trạng thái Payment:
```
PENDING → SUCCESS (thanh toán thành công)
PENDING → CANCELLED (booking bị hủy trước khi thanh toán)
PENDING → FAILED (lỗi giao dịch)
SUCCESS → REFUND_PENDING (yêu cầu hoàn tiền)
REFUND_PENDING → REFUNDED (hoàn tiền xong)
```

### Thanh toán tại quầy (CASH):
1. Khách hàng đến cơ sở
2. STAFF vào StaffCashierPage, tra cứu hóa đơn theo booking hoặc tên khách
3. STAFF xác nhận thu tiền → `PUT /payment/:id/status` với `{ status: 'SUCCESS', method: 'CASH' }`
4. Hệ thống tự động cập nhật booking → CONFIRMED

### Thanh toán ZaloPay:
1. CUSTOMER chọn thanh toán ZaloPay từ màn hình hóa đơn
2. Gọi `POST /zalopay/create-order` → nhận URL thanh toán
3. Mở WebView hoặc App ZaloPay
4. Thanh toán xong, ZaloPay gọi callback về server
5. Server xác thực HMAC signature
6. Cập nhật payment → SUCCESS, ghi `transaction_id`
7. Nếu booking liên kết → cập nhật CONFIRMED
8. Flutter polling `POST /zalopay/query` để cập nhật UI

### Xử lý khi booking bị hủy:
- Payment PENDING → chuyển CANCELLED
- Payment SUCCESS → có thể chuyển REFUND_PENDING (thủ công bởi ADMIN)
- **Hoàn tiền tự động: Chưa triển khai** – hiện chỉ có trường `refunded_at`, `refunded_by`, `refund_reason` trong model

### Điểm còn mô phỏng:
- MOMO, VNPAY, BANK_TRANSFER có trong enum `method` nhưng **chưa tích hợp logic**
- Chỉ ZaloPay và CASH có luồng xử lý đầy đủ
- Hoàn tiền tự động cần xử lý thủ công bởi ADMIN

---

## 8.5 Nghiệp vụ Báo cáo

### Báo cáo Staff (`GET /api/v1/reports/court-performance`):
- **Mục đích:** Giúp Staff theo dõi hiệu suất từng sân tại cơ sở
- **Bộ lọc:**
  - `facility_id` (bắt buộc)
  - `from` và `to` (khoảng ngày)
  - `sport_id` (tùy chọn)
- **Chỉ số tính:**
  - `total_bookings`: Tổng số booking
  - `confirmed_bookings`: Số booking đã xác nhận/hoàn thành
  - `total_revenue`: Tổng doanh thu (tính từ Payment SUCCESS)
  - `occupancy_rate`: Tỷ lệ lấp đầy = (thời gian đã đặt / tổng thời gian hoạt động)
- **File:** `report.service.js`, `reports.controller.js`

### Báo cáo Admin (`GET /api/v1/reports/advanced-performance`):
- **Mục đích:** Tổng quan toàn hệ thống
- **Bộ lọc:** Khoảng thời gian, cơ sở (tùy chọn)
- **Chỉ số tính:**
  - Tổng doanh thu toàn hệ thống
  - Số lượng booking theo trạng thái
  - Số phiên ghép trận OPEN/FULL/COMPLETED
  - Số lịch cố định ACTIVE/PENDING
  - Booking trend theo ngày/tuần/tháng
  - Court utilization per facility
- **Hiển thị:** Biểu đồ Recharts (line chart, bar chart) trong `admin_overview_page.tsx`
- **File:** `report.service.js`, `reports.controller.js`

### Tính Revenue:
- Revenue chỉ tính từ Payment có `status: SUCCESS`
- Liên kết payment → booking → court → facility để tổng hợp theo cơ sở
- Hỗ trợ lọc theo nhiều cơ sở hoặc toàn hệ thống
