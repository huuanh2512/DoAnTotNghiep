# 8. NGHIỆP VỤ CHI TIẾT

## 8.1 Nghiệp vụ Đặt sân

**File chính**: `src/services/booking.service.js` (38KB), `src/services/court-availability.service.js`, `src/services/booking-price.service.js`

### Điều kiện tạo booking

1. **Người dùng**: Phải có JWT hợp lệ (đã đăng nhập)
2. **Sân (Court)**: `status === 'ACTIVE'`
3. **Thời gian hợp lệ**:
   - `start_minutes < end_minutes`
   - `booking_date` không phải quá khứ
   - Trong khoảng `opening_minutes` đến `closing_minutes` của slot_config

### Kiểm tra trùng lịch (Conflict Detection)

Hệ thống kiểm tra theo thứ tự:

**Kiểm tra 1 — Booking conflict**:
```
Query: Booking có court_id = x, booking_date = ngày, 
       status IN [PENDING, CONFIRMED, COMPLETED],
       start_minutes < request.end_minutes, 
       end_minutes > request.start_minutes
→ Nếu có kết quả → SLOT_CONFLICT
```

**Kiểm tra 2 — Court Block conflict**:
```
Query: CourtBlock có (court_id = x OR court_id null với facility_id),
       status = ACTIVE,
       start_time < datetime(date+end_minutes),
       end_time > datetime(date+start_minutes)
→ Nếu có kết quả → COURT_BLOCKED
```

**Kiểm tra 3 — Fixed Schedule conflict**:
```
Dựa trên booking đã sinh từ fixed schedule, 
đã được kiểm tra trong Booking conflict ở trên
```

### Tính giá

**Service**: `src/services/booking-price.service.js`

```
duration_minutes = end_minutes - start_minutes
duration_hours = duration_minutes / 60
total_price = court.price_per_hour × duration_hours
```

Ví dụ: Sân giá 150,000 VNĐ/giờ, đặt 90 phút → 225,000 VNĐ

### Trạng thái booking

```
PENDING → CONFIRMED (STAFF duyệt, hoặc STAFF tạo cho walk-in → tự CONFIRMED)
PENDING → CANCELLED (CUSTOMER/STAFF/ADMIN hủy, hoặc Cron tự hủy sau 15 phút)
CONFIRMED → CANCELLED (STAFF/ADMIN hủy)
CONFIRMED → COMPLETED (Cron tự động sau khi giờ chơi kết thúc)
```

### Khi nào được hủy
- CUSTOMER: chỉ hủy booking `status IN [PENDING, CONFIRMED]` của chính mình
- STAFF/ADMIN: hủy bất kỳ booking nào trong facility
- Booking COMPLETED không thể hủy

### Auto Cancel (Cron)

**File**: `src/utils/cron-auto-cancel-bookings.js`  
**Lịch**: Mỗi 1 phút (`*/1 * * * *`)  
**Logic**: Tìm booking `status = PENDING` mà `created_at < now - 15 phút` (hoặc theo cấu hình) → set CANCELLED, cập nhật Payment → CANCELLED

### Auto Complete (Cron)

**File**: `src/utils/cron-auto-complete-bookings.js`  
**Lịch**: Mỗi 1 phút (`*/1 * * * *`)  
**Logic**: Tìm booking `status = CONFIRMED` mà `booking_date + end_minutes < now (giờ Việt Nam)` → set COMPLETED; cũng set MatchingSession liên kết → COMPLETED

### Notification liên quan

| Sự kiện | Người nhận | Channel |
|---------|-----------|---------|
| Booking mới PENDING | STAFF (facility) | Socket.IO room_staff + FCM |
| Booking CONFIRMED | CUSTOMER | Socket.IO user_room + FCM |
| Booking CANCELLED | CUSTOMER | Socket.IO user_room + FCM |
| Booking COMPLETED | CUSTOMER | Socket.IO user_room |

### Payment liên quan

- Khi booking PENDING → tự động tạo Payment PENDING
- Khi booking CANCELLED → Payment → CANCELLED
- Khi booking CONFIRMED + Payment SUCCESS → hoàn tất
- Payment có thể có nhiều method: CASH (staff thu tiền mặt) hoặc ZALOPAY (online)

---

## 8.2 Nghiệp vụ Lịch cố định

**File chính**: `src/services/fixed-schedule.service.js` (77KB), `src/repositories/fixed-schedule.repository.js`

### Tạo lịch cố định

CUSTOMER gửi request với:
- `type`: `COURT_BOOKING` (chỉ đặt sân) hoặc `MATCHING` (đặt sân + ghép trận)
- `frequency`: `DAILY` hoặc `WEEKLY`
- `days_of_week`: [0-6] nếu WEEKLY (0=CN, 1=T2...6=T7)
- `start_date`, `end_date` (optional)
- Thông tin sân và giờ

Service kiểm tra:
1. Sân còn ACTIVE không
2. Có conflict với booking/lịch cố định đang tồn tại trong tuần đầu tiên không

Kết quả: FixedSchedule với `status: PENDING_APPROVAL`

### Duyệt lịch cố định

STAFF/ADMIN gọi `PUT /fixed-schedule/:id/approve`

Service thực hiện:
1. Cập nhật `status → ACTIVE`, lưu `approved_by`, `approved_at`
2. Gọi `generateBookingsForRange(schedule, today, today+14days)`
3. Sinh booking cho các ngày trong range (bỏ qua exception_dates, bỏ qua conflict)
4. Nếu `type === MATCHING`: sinh MatchingSession cho mỗi ngày

### Sinh booking tự động (generateBookingsForRange)

Logic tính danh sách ngày cần sinh:
```
if DAILY:
  dates = [fromDate → toDate] 
if WEEKLY:
  dates = [d in fromDate→toDate where d.dayOfWeek IN days_of_week]
  
Loại bỏ exception_dates
Loại bỏ ngày trước start_date hoặc sau end_date
Cho mỗi date còn lại:
  Kiểm tra booking đã tồn tại chưa (unique partial index)
  Nếu chưa → Booking.create({ ..., fixed_schedule_id, is_fixed_schedule: true })
```

### Cron Job: fixedScheduler

**File**: `src/utils/cron-fixed-scheduler.js`  
**Lịch**: `5 0 * * *` (00:05 hàng ngày, múi giờ Asia/Ho_Chi_Minh)  
**Startup**: Chạy thêm sau 5 giây khi khởi động server  
**Logic**:
1. Lấy tất cả FixedSchedule `status = ACTIVE`
2. Range sinh: `getAdvanceGenerationRange()` → [today, today+N ngày] (N được cấu hình trong service)
3. Với mỗi schedule: `generateBookingsForRange(schedule, from, to)`
4. Xử lý lỗi từng schedule độc lập (failedSchedules counter)

**Rủi ro khi deploy Render free**:
- Render free tier sleep sau 15 phút không có request
- Cron 00:05 có thể không chạy nếu server đang sleep
- **Giải pháp**: Đã có script startup scan (chạy lại khi server wake up), và cron UptimeRobot ping giữ server sống

### Tạm dừng/Tiếp tục

- `PAUSE`: `status → PAUSED`, lưu `paused_at` → cron không sinh booking nữa
- `RESUME`: `status → ACTIVE` → cron tiếp tục sinh booking từ ngày hiện tại

### Hủy một buổi (Exception Date)

Khi CUSTOMER muốn bỏ một ngày cụ thể:
1. `POST /fixed-schedule/:id/occurrences/2024-12-25/cancel`
2. Service thêm `exception_dates: [{ date: '2024-12-25', type: 'CANCELLED', reason }]`
3. Booking đã sinh cho ngày đó → hủy (CANCELLED)
4. Cron tương lai sẽ bỏ qua ngày này

### Hủy cả chuỗi

`PUT /fixed-schedule/:id/cancel` → `status → CANCELLED` → Tất cả booking PENDING liên quan → CANCELLED

### Conflict handling

Nếu sinh booking mà bị conflict (unique index violation):
- Cron bỏ qua, không dừng toàn bộ
- Log lỗi nhưng tiếp tục các ngày/schedules khác

### Quyền Customer/Staff/Admin

| Hành động | CUSTOMER | STAFF | ADMIN |
|-----------|---------|-------|-------|
| Tạo | ✅ (của mình) | ✅ | ✅ |
| Duyệt/Từ chối | ❌ | ✅ | ✅ |
| Tạm dừng/Tiếp tục | ❌ | ✅ | ✅ |
| Hủy một buổi | ✅ (của mình) | ✅ | ✅ |
| Hủy cả chuỗi | ✅ (của mình) | ✅ | ✅ |

### Payment cho lịch cố định

- Mỗi booking sinh ra từ fixed schedule → có payment PENDING riêng
- CUSTOMER phải thanh toán từng buổi (hoặc STAFF thu tiền mặt)
- Không có thanh toán trọn gói (theo code hiện tại)

---

## 8.3 Nghiệp vụ Ghép trận

**File chính**: `src/services/matching.service.js` (70KB), `src/repositories/matching.repository.js`, `src/repositories/match-queue.repository.js`

### Manual Matching (Tạo thủ công)

**CUSTOMER** tạo MatchingSession với:
- Booking đã có (hoặc auto tạo booking)
- `total_players_needed`: số chân cần tuyển thêm
- `team_mode`:
  - `INDIVIDUAL`: không phân đội, tổng số người đủ là FULL
  - `TEAM_FILL`: có 2 đội A và B, fill đủ mỗi đội
  - `TEAM_VS_TEAM`: hai đội đối đầu, cân bằng players
- `auto_approve`: true → member join tự động APPROVED; false → host phải duyệt thủ công
- `payment_policy`: quy định ai trả tiền

### Auto Matching (Hàng đợi)

**CUSTOMER** vào hàng đợi với tiêu chí tìm kiếm:
- `sport_id`, `facility_id`, `booking_date`, `start_minutes`, `end_minutes`
- `group_size`: tổng số người muốn ghép
- `team_mode`, `payment_policy`

**Cron Matchmaker** chạy mỗi phút:
1. Lấy tất cả MatchQueue `status = SEARCHING` cho ngày hôm nay
2. Nhóm theo `sport_id + facility_id + date`
3. Với mỗi nhóm, chạy `runMatchmakerAlgorithm()`:
   - Tìm các entry có thời gian overlap và tiêu chí tương thích
   - Nếu tổng `member_count` đạt `group_size` → tạo booking tự động + MatchingSession
   - Cập nhật queue entries → MATCHED với `matching_session_id`
   - Thông báo tất cả players
4. Hủy các session/queue OPEN quá lâu (`autoCancelUnmatched()`)

### Matching Queue
- Mỗi MatchQueue entry là 1 user/nhóm đang chờ
- `member_count`: entry này đại diện bao nhiêu người
- `team_size`, `preferred_team`: cho TEAM mode
- `claim_token`: token nội bộ để prevent race condition khi claim slot

### Matching Session
- Host tự động có `member.status = APPROVED`
- `teams[]`: mảng team info (A, B với max_players)
- `members[]`: mảng thành viên thực tế
- Khi `sum(approved_members.represented_count) >= total_players_needed` → `status: FULL`

### Team Mode Detail

| Mode | Mô tả | Khi FULL |
|------|-------|---------|
| `INDIVIDUAL` | Không phân đội | Tổng approved >= total_players_needed |
| `TEAM_FILL` | Phân vào 2 đội, có thể không cân bằng | Tổng >= total_players_needed |
| `TEAM_VS_TEAM` | 2 đội phải cân bằng | Mỗi đội đủ max_players |

### Join/Leave logic

**Join**:
- Kiểm tra session OPEN, không FULL
- Kiểm tra user chưa là member
- Thêm member với PENDING (nếu auto_approve=false) hoặc APPROVED
- Kiểm tra FULL condition → cập nhật session status

**Leave**:
- Host không thể leave (chỉ cancel session)
- Member APPROVED leave → trừ count → session có thể trở lại OPEN

### Payment policy cho ghép trận

| Policy | Mô tả | Áp dụng |
|--------|-------|---------|
| `HOST_PAY_ALL` | Host trả toàn bộ tiền sân | Host tự quản lý |
| `SPLIT_EQUALLY` | Chia đều cho tất cả member | Thỏa thuận thủ công ngoài app |
| `TEAM_REPRESENTATIVES_SPLIT` | Đại diện mỗi đội chia nhau | Áp dụng TEAM_VS_TEAM |

> **Lưu ý**: Payment policy hiện tại là thỏa thuận hiển thị trong UI, chưa có cơ chế tự động thu tiền từ từng member. Đây là điểm cần phát triển trong tương lai.

### Khi nào tạo booking trong Auto Match

Khi cron match thành công:
1. Tìm sân còn trống cho slot đó
2. `Booking.create(...)` cho slot tự chọn → CONFIRMED ngay
3. `MatchingSession.create(...)` liên kết với booking
4. `MatchQueue.updateMany({ status: MATCHED })` cho tất cả entries tham gia

### Khi session FULL / CANCELLED

- `FULL`: Tất cả approved members đủ số → session closed cho join mới → vẫn chờ chơi
- `CANCELLED`: Host cancel hoặc cron auto-cancel unmatched session sau timeout
- `COMPLETED`: Cron auto-complete sau khi giờ chơi kết thúc

### Notification liên quan

| Sự kiện | Người nhận | Channel |
|---------|-----------|---------|
| Member mới join (auto_approve=false) | Host | Socket.IO user_room |
| Member được APPROVED | Member | Socket.IO user_room |
| Session FULL | Tất cả members | Socket.IO matching_room |
| Auto matched | Tất cả queue players | Socket.IO user_room + FCM |
| Session cập nhật | Tất cả trong room | Socket.IO matching_room |

---

## 8.4 Nghiệp vụ Thanh toán/Hóa đơn

**File chính**: `src/services/payment.service.js` (20KB), `src/services/zalopay.service.js`

### Payment được tạo khi nào

1. **Booking PENDING tạo mới** → Auto tạo Payment PENDING, method mặc định CASH
2. **CUSTOMER chọn phương thức online** → Update/Create payment với method ZALOPAY
3. **STAFF tạo booking cho walk-in** → Tạo Payment PENDING (CASH)

### Trạng thái Payment

```
PENDING → SUCCESS (thanh toán thành công)
PENDING → FAILED (thanh toán thất bại)
PENDING → CANCELLED (booking bị hủy, hoặc user cancel)
SUCCESS → REFUND_PENDING (yêu cầu hoàn tiền)
REFUND_PENDING → REFUNDED (hoàn tiền thành công)
```

### Liên kết Payment với Booking

- Mỗi Booking có tối đa 1 Payment `PENDING` hoặc `SUCCESS` tại cùng thời điểm (unique partial index)
- Khi booking CANCELLED → Payment → CANCELLED (trừ REFUNDED)
- Khi Payment → SUCCESS → Booking → CONFIRMED (áp dụng cho online payment)

### Thanh toán tiền mặt (CASH)

STAFF gọi `PUT /payment/:id/status { status: 'SUCCESS' }`:
- Payment → SUCCESS
- Booking → CONFIRMED (nếu chưa CONFIRMED)
- Thông báo CUSTOMER

### Tích hợp ZaloPay

**File**: `src/controllers/zalopay.controller.js` (10KB), `src/services/zalopay.service.js`

Quy trình:
1. Flutter gọi `POST /zalopay/create-order { paymentId }`
2. Backend gọi ZaloPay API tạo order: `POST https://sb-openapi.zalopay.vn/v2/create`
   - `app_id`, `app_key` từ env (Sandbox credentials)
   - `app_trans_id`: unique ID theo format `yyMMdd_paymentId_timestamp`
   - `amount`: từ payment.amount
   - `callback_url`: backend URL nhận kết quả
3. ZaloPay trả về: `{ order_url, deeplink_url, qr_code, app_trans_id }`
4. Backend lưu các URL vào Payment document
5. Flutter mở WebView với `order_url`
6. Sau khi thanh toán, ZaloPay gọi `POST /zalopay/callback`
7. Backend verify HMAC-SHA256 với `zalopay_key2`
8. Nếu hợp lệ → `return_code = 1` → Payment → SUCCESS
9. Flutter có thể polling `POST /zalopay/query` để kiểm tra

**Biến môi trường ZaloPay** (chỉ liệt kê tên, không hiển thị giá trị):
- `ZALOPAY_APP_ID`: ID ứng dụng ZaloPay
- `ZALOPAY_KEY1`: Key 1 dùng để tạo MAC
- `ZALOPAY_KEY2`: Key 2 dùng để verify callback
- `ZALOPAY_CALLBACK_URL`: URL callback server

**Hiện trạng**: Đang dùng Sandbox (`sb-openapi.zalopay.vn`). Để production cần thay sang `openapi.zalopay.vn` và dùng merchant credentials thật.

### Refund

- `REFUND_PENDING`, `REFUNDED` có trong Payment model (enum)
- `refunded_at`, `refunded_by`, `refund_reason` có trong Payment
- **Chưa có flow tự động**: Refund hiện tại phải thực hiện thủ công qua dashboard ZaloPay hoặc ADMIN update trực tiếp
- Chưa có giao diện chuyên biệt cho refund trong web hoặc mobile

### Điểm còn mô phỏng/chưa tích hợp

1. **VNPay, MoMo, BANK_TRANSFER**: Có enum trong model nhưng chưa có controller/service xử lý
2. **Refund tự động**: Chưa có, phải xử lý thủ công
3. **ZaloPay production**: Đang ở Sandbox
4. **Mock payment page**: `mock_payment_page.dart` dùng cho dev, không dùng production

---

## 8.5 Nghiệp vụ Báo cáo

**File chính**: `src/services/report.service.js` (41KB)  
**Controller**: `src/controllers/reports.controller.js`

### Báo cáo Staff — Court Performance

**API**: `GET /api/v1/reports/court-performance`  
**Quyền**: STAFF, ADMIN  
**Query params**: `facility_id`, `from` (YYYY-MM-DD), `to` (YYYY-MM-DD), `sport_id` (optional), `status` (optional)

**Các chỉ số tính**:
| Chỉ số | Mô tả | Nguồn dữ liệu |
|--------|-------|---------------|
| `booking_count` | Số booking trong khoảng | Booking collection (status = CONFIRMED + COMPLETED) |
| `cancelled_count` | Số booking bị hủy | Booking (status = CANCELLED) |
| `revenue` | Doanh thu | Payment (status = SUCCESS) liên kết với booking |
| `utilization_rate` | Tỷ lệ lấp đầy | booking_hours / available_hours × 100% |
| `average_booking_duration` | Thời gian đặt trung bình | (end_minutes - start_minutes) trung bình |

**Dữ liệu aggregate** theo từng sân (Court) trong facility, trả về mảng:
```json
{
  "courts": [
    {
      "court_id": "...",
      "court_name": "Sân 1",
      "sport_name": "Bóng đá",
      "booking_count": 45,
      "cancelled_count": 3,
      "revenue": 6750000,
      "utilization_rate": 0.75
    }
  ],
  "summary": {
    "total_revenue": 15000000,
    "total_bookings": 100,
    "total_cancelled": 8
  }
}
```

### Báo cáo Admin — Advanced Performance

**API**: `GET /api/v1/reports/advanced-performance`  
**Quyền**: ADMIN  
**Query params**: `facility_id`, `from`, `to`, `group_by` (day/week/month)

**Các chỉ số tính**:
| Chỉ số | Mô tả |
|--------|-------|
| `revenue_trend` | Doanh thu theo ngày/tuần/tháng (LineChart) |
| `top_courts` | Top 5 sân doanh thu cao nhất |
| `top_sports` | Top môn thể thao theo booking count |
| `booking_by_status` | Phân phối booking theo trạng thái (PieChart) |
| `daily_stats` | Thống kê theo từng ngày trong range |
| `total_revenue` | Tổng doanh thu |
| `total_bookings` | Tổng booking |
| `new_customers` | Số khách hàng mới |

### Bộ lọc báo cáo

- Theo ngày: `from`, `to` (YYYY-MM-DD)
- Theo cơ sở: `facility_id` (STAFF chỉ thấy facility mình quản lý; ADMIN xem tất cả)
- Theo môn thể thao: `sport_id` (nếu có)
- Theo trạng thái booking: `status` filter

### Revenue tính theo Payment nào

Chỉ tính Payment có `status = 'SUCCESS'`, không tính PENDING/CANCELLED/REFUNDED.

Revenue = `SUM(payment.amount)` where `payment.booking_id IN [booking_ids trong filter]`
