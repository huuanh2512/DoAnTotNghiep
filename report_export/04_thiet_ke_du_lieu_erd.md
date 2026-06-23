# 5. THIẾT KẾ DỮ LIỆU VÀ ERD

## 5.1 Danh sách Model/Schema MongoDB

| Tên Model | Collection | Mục đích | File định nghĩa | Quan hệ chính |
|-----------|-----------|----------|----------------|---------------|
| **User** | users | Tài khoản người dùng, phân quyền, FCM tokens | `src/models/user.model.js` | → Facility (facility_id) |
| **Facility** | facilities | Thông tin cơ sở thể thao | `src/models/facility.model.js` | ← User (staff_ids) |
| **Sport** | sports | Môn thể thao | `src/models/sport.model.js` | ← Court (sport_id) |
| **Court** | courts | Sân thể thao, bao gồm SlotConfig | `src/models/court.model.js` | → Facility, → Sport; Embedded SlotConfig |
| **CourtBlock** | courtblocks | Block/bảo trì sân trong khoảng thời gian | `src/models/court-block.model.js` | → Facility, → Court, → User (created_by) |
| **Booking** | bookings | Lượt đặt sân | `src/models/booking.model.js` | → User, → Court, → FixedSchedule |
| **Payment** | payments | Hóa đơn thanh toán | `src/models/payment.model.js` | → Booking, → User, → User (refunded_by) |
| **Notification** | notifications | Thông báo trong app | `src/models/notification.model.js` | → User |
| **MatchingSession** | matchingsessions | Phòng ghép trận | `src/models/matching.model.js` | → User (host), → Sport, → Facility, → Court, → Booking, → FixedSchedule; Embedded Member, Team |
| **MatchQueue** | matchqueues | Hàng đợi ghép trận tự động | `src/models/match-queue.model.js` | → User, → Sport, → Facility, → MatchingSession |
| **FixedSchedule** | fixedschedules | Lịch đặt sân cố định định kỳ | `src/models/fixed-schedule.model.js` | → User, → Sport, → Facility, → Court, → User (approved_by, rejected_by); Embedded ExceptionDate, MatchingConfig |
| **Review** | reviews | Đánh giá sân sau khi chơi | `src/models/review.model.js` | → User, → Court |

---

## 5.2 Chi tiết từng thực thể

---

### Model: User

**File**: `src/models/user.model.js` | **Collection**: `users`

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mặc định | Enum / Ràng buộc | Diễn giải nghiệp vụ |
|-----------|-------------|---------|---------|---------|---------------------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `email` | String | ✅ | - | unique, trim, lowercase | Email đăng nhập duy nhất |
| `password` | String | ❌ | null | - | Null nếu dùng Firebase Auth |
| `firebaseUid` | String | ❌ | null | unique, sparse | UID từ Firebase (Google login) |
| `role` | String | ❌ | CUSTOMER | `CUSTOMER`, `STAFF`, `ADMIN` | Quyền hạn trong hệ thống |
| `status` | String | ❌ | PENDING_OTP | `PENDING_OTP`, `PENDING_EMAIL`, `ACTIVE`, `INACTIVE`, `BANNED` | Trạng thái tài khoản |
| `profile.name` | String | ❌ | '' | - | Tên hiển thị |
| `profile.phone` | String | ❌ | '' | - | Số điện thoại |
| `profile.avatar_url` | String | ❌ | '' | - | URL ảnh đại diện (Cloudinary) |
| `facility_id` | ObjectId | ❌ | null | ref: Facility | STAFF liên kết với cơ sở |
| `fcmTokens` | [String] | ❌ | [] | - | Danh sách FCM token thiết bị |
| `resetPasswordOtp` | String | ❌ | null | - | OTP reset mật khẩu (hash) |
| `resetPasswordOtpExpires` | Date | ❌ | null | - | Thời gian hết hạn OTP reset |
| `emailVerifiedAt` | Date | ❌ | null | - | Thời điểm xác thực email thành công |
| `emailVerificationOtpHash` | String | ❌ | null | - | Hash OTP xác thực email |
| `emailVerificationExpiresAt` | Date | ❌ | null | - | Hết hạn OTP xác thực |
| `emailVerificationAttempts` | Number | ❌ | 0 | min: 0 | Số lần thử OTP (chống brute force) |
| `emailVerificationLockedUntil` | Date | ❌ | null | - | Khóa gửi OTP đến thời điểm này |
| `created_at` | Date | Auto | - | timestamps | Ngày tạo |
| `updated_at` | Date | Auto | - | timestamps | Ngày cập nhật |

---

### Model: Facility

**File**: `src/models/facility.model.js` | **Collection**: `facilities`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Diễn giải |
|-----------|------|---------|---------|-----------|
| `_id` | ObjectId | Auto | - | Primary key |
| `name` | String | ✅ | - | Tên cơ sở thể thao |
| `address.city` | String | ❌ | '' | Tên thành phố |
| `address.full` | String | ❌ | '' | Địa chỉ đầy đủ |
| `active` | Boolean | ❌ | true | Cơ sở đang hoạt động không |
| `staff_ids` | [ObjectId] | ❌ | [] | ref: User — Danh sách nhân viên |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

### Model: Sport

**File**: `src/models/sport.model.js` | **Collection**: `sports`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Diễn giải |
|-----------|------|---------|---------|-----------|
| `_id` | ObjectId | Auto | - | Primary key |
| `name` | String | ✅ | - | Tên môn thể thao (Bóng đá, Cầu lông...) |
| `description` | String | ❌ | '' | Mô tả ngắn |
| `icon_url` | String | ❌ | '' | URL icon môn thể thao |
| `team_size` | Number | ❌ | 0 | Số người mỗi đội (tham khảo) |
| `active` | Boolean | ❌ | true | Môn thể thao đang hoạt động không |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

### Model: Court (bao gồm SlotConfig và CourtSlot embedded)

**File**: `src/models/court.model.js` | **Collection**: `courts`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `name` | String | ✅ | - | - | Tên sân (Sân 1, Sân A...) |
| `facility_id` | ObjectId | ✅ | - | ref: Facility | Sân thuộc cơ sở nào |
| `sport_id` | ObjectId | ✅ | - | ref: Sport | Môn thể thao của sân |
| `code` | String | ❌ | '' | - | Mã sân nội bộ |
| `status` | String | ❌ | ACTIVE | `ACTIVE`, `INACTIVE`, `MAINTENANCE` | Trạng thái hoạt động |
| `price_per_hour` | Number | ❌ | 0 | - | Giá thuê sân theo giờ (VNĐ) |
| `slot_config.opening_minutes` | Number | ❌ | 360 | - | Giờ mở cửa (phút từ 00:00, 360 = 6:00) |
| `slot_config.closing_minutes` | Number | ❌ | 1320 | - | Giờ đóng cửa (phút, 1320 = 22:00) |
| `slot_config.slot_duration_minutes` | Number | ❌ | 60 | - | Độ dài mỗi slot (phút) |
| `slot_config.slots[].slot_index` | Number | - | - | - | Số thứ tự slot |
| `slot_config.slots[].start_minutes` | Number | - | - | - | Giờ bắt đầu slot (phút) |
| `slot_config.slots[].end_minutes` | Number | - | - | - | Giờ kết thúc slot (phút) |
| `slot_config.slots[].is_available` | Boolean | - | - | - | Slot có khả dụng không |
| `slot_config.slots[].mode` | String | - | AVAILABLE | - | Chế độ slot |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

### Model: CourtBlock

**File**: `src/models/court-block.model.js` | **Collection**: `courtblocks`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `facility_id` | ObjectId | ✅ | - | ref: Facility | Cơ sở bị block |
| `court_id` | ObjectId | ❌ | null | ref: Court | Sân cụ thể (null = toàn bộ cơ sở) |
| `start_time` | Date | ✅ | - | - | Thời điểm bắt đầu block |
| `end_time` | Date | ✅ | - | - | Thời điểm kết thúc block |
| `reason` | String | ❌ | '' | - | Lý do block/bảo trì |
| `type` | String | ❌ | MANUAL_BLOCK | `MAINTENANCE`, `HOLIDAY`, `MANUAL_BLOCK`, `CLOSED`, `OTHER` | Loại block |
| `status` | String | ❌ | ACTIVE | `ACTIVE`, `CANCELLED` | Trạng thái block |
| `created_by` | ObjectId | ✅ | - | ref: User | Người tạo block |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

**Ràng buộc**: Pre-validate hook kiểm tra `start_time < end_time`
**Index**: Compound `{ facility_id, court_id, status, start_time, end_time }`

---

### Model: Booking

**File**: `src/models/booking.model.js` | **Collection**: `bookings`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `user_id` | ObjectId | ❌ | null | ref: User | Khách đặt (null nếu walk-in) |
| `guest_name` | String | ❌ | null | - | Tên khách vãng lai |
| `guest_phone` | String | ❌ | null | - | SĐT khách vãng lai |
| `court_id` | ObjectId | ✅ | - | ref: Court | Sân đặt |
| `booking_date` | String | ✅ | - | format YYYY-MM-DD | Ngày đặt |
| `start_minutes` | Number | ✅ | - | - | Giờ bắt đầu (phút từ 00:00) |
| `end_minutes` | Number | ✅ | - | - | Giờ kết thúc (phút từ 00:00) |
| `total_price` | Number | ❌ | 0 | - | Giá tổng (VNĐ) |
| `status` | String | ❌ | PENDING | `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED` | Trạng thái booking |
| `fixed_schedule_id` | ObjectId | ❌ | null | ref: FixedSchedule | Nếu thuộc lịch cố định |
| `is_fixed_schedule` | Boolean | ❌ | false | - | Đánh dấu sinh từ lịch cố định |
| `cancel_reason` | String | ❌ | null | - | Lý do hủy |
| `cancelled_by` | String | ❌ | null | - | Ai hủy (userId hoặc 'SYSTEM') |
| `cancelled_at` | Date | ❌ | null | - | Thời điểm hủy |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

**Indexes**:
- `{ status, booking_date, start_minutes }`
- `{ fixed_schedule_id, status, booking_date }`
- Unique partial: `{ fixed_schedule_id, court_id, booking_date, start_minutes, end_minutes }` where `status in [PENDING, CONFIRMED, COMPLETED]`

---

### Model: Payment

**File**: `src/models/payment.model.js` | **Collection**: `payments`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `booking_id` | ObjectId | ✅ | - | ref: Booking | Hóa đơn cho booking nào |
| `user_id` | ObjectId | ✅ | - | ref: User | Người thanh toán |
| `amount` | Number | ✅ | - | - | Số tiền (VNĐ) |
| `method` | String | ❌ | CASH | `CASH`, `BANK_TRANSFER`, `MOMO`, `ZALOPAY`, `VNPAY` | Phương thức thanh toán |
| `status` | String | ❌ | PENDING | `PENDING`, `SUCCESS`, `FAILED`, `CANCELLED`, `REFUND_PENDING`, `REFUNDED` | Trạng thái thanh toán |
| `transaction_id` | String | ❌ | '' | - | ID giao dịch từ cổng thanh toán |
| `zalopay_order_url` | String | ❌ | '' | - | URL trang thanh toán ZaloPay |
| `zalopay_deeplink_url` | String | ❌ | '' | - | Deeplink mở app ZaloPay |
| `zalopay_qr_code` | String | ❌ | '' | - | URL QR code ZaloPay |
| `zalopay_created_at` | Date | ❌ | null | - | Thời điểm tạo order ZaloPay |
| `refunded_at` | Date | ❌ | null | - | Thời điểm hoàn tiền |
| `refunded_by` | ObjectId | ❌ | null | ref: User | Ai thực hiện hoàn tiền |
| `refund_reason` | String | ❌ | null | - | Lý do hoàn tiền |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

**Index Unique Partial**: `{ booking_id, user_id }` where `status in [PENDING, SUCCESS]` — Đảm bảo không có 2 payment active cho cùng booking

---

### Model: Notification

**File**: `src/models/notification.model.js` | **Collection**: `notifications`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `userId` | ObjectId | ✅ | - | ref: User, index | Người nhận |
| `title` | String | ✅ | - | - | Tiêu đề thông báo |
| `content` | String | ✅ | - | - | Nội dung thông báo |
| `type` | String | ❌ | SYSTEM | `BOOKING`, `PAYMENT`, `SYSTEM`, `PROMOTION` | Loại thông báo |
| `audience` | String | ❌ | ALL | `CUSTOMER`, `STAFF`, `ADMIN`, `ALL` | Đối tượng nhận |
| `metadata.bookingId` | String | ❌ | - | - | ID booking liên quan |
| `metadata.paymentId` | String | ❌ | - | - | ID payment liên quan |
| `metadata.matchingSessionId` | String | ❌ | - | - | ID session ghép trận liên quan |
| `metadata.link` | String | ❌ | - | - | Deep link |
| `isRead` | Boolean | ❌ | false | - | Đã đọc chưa |
| `createdAt` | Date | Auto | - | timestamps | Ngày tạo |

**Index**: `{ userId, audience, isRead, createdAt: -1 }` — tối ưu query thông báo chưa đọc

---

### Model: MatchingSession (bao gồm Member + Team embedded)

**File**: `src/models/matching.model.js` | **Collection**: `matchingsessions`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `host_id` | ObjectId | ✅ | - | ref: User | Chủ phòng ghép trận |
| `sport_id` | ObjectId | ✅ | - | ref: Sport | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | ref: Facility | Cơ sở tổ chức |
| `court_id` | ObjectId | ✅ | - | ref: Court | Sân thi đấu |
| `booking_id` | ObjectId | ❌ | null | ref: Booking | Booking liên kết |
| `fixed_schedule_id` | ObjectId | ❌ | null | ref: FixedSchedule | Nếu từ lịch cố định |
| `booking_date` | String | ✅ | - | YYYY-MM-DD | Ngày thi đấu |
| `start_minutes` | Number | ✅ | - | - | Giờ bắt đầu (phút) |
| `end_minutes` | Number | ✅ | - | - | Giờ kết thúc (phút) |
| `total_players_needed` | Number | ✅ | - | min: 1 | Tổng số chân cần tuyển |
| `team_mode` | String | ❌ | INDIVIDUAL | `INDIVIDUAL`, `TEAM_FILL`, `TEAM_VS_TEAM` | Chế độ đội |
| `host_team_code` | String | ❌ | A | `A`, `B` | Đội của host |
| `host_represented_count` | Number | ❌ | 1 | min: 1 | Host đại diện bao nhiêu người |
| `teams[].team_code` | String | - | - | `A`, `B` | Mã đội |
| `teams[].name` | String | - | '' | - | Tên đội |
| `teams[].max_players` | Number | - | - | min: 1 | Tối đa player mỗi đội |
| `teams[].representative_user_id` | ObjectId | - | null | ref: User | Đại diện đội |
| `description` | String | ❌ | '' | - | Mô tả thêm |
| `auto_approve` | Boolean | ❌ | true | - | Tự động duyệt member |
| `payment_policy` | String | ❌ | HOST_PAY_ALL | `HOST_PAY_ALL`, `SPLIT_EQUALLY`, `TEAM_REPRESENTATIVES_SPLIT` | Chính sách chia tiền |
| `members[].user_id` | ObjectId | ✅ | - | ref: User | ID thành viên |
| `members[].status` | String | - | PENDING | `PENDING`, `APPROVED`, `REJECTED` | Trạng thái thành viên |
| `members[].team_code` | String | - | null | `A`, `B` | Thuộc đội nào |
| `members[].represented_count` | Number | - | 1 | min: 1 | Đại diện bao nhiêu người |
| `members[].join_mode` | String | - | INDIVIDUAL | `INDIVIDUAL`, `TEAM_REPRESENTATIVE` | Kiểu tham gia |
| `members[].team_name` | String | - | '' | max: 100 | Tên đội của member |
| `members[].note` | String | - | '' | max: 500 | Ghi chú |
| `members[].joined_at` | Date | - | Date.now | - | Thời điểm tham gia |
| `status` | String | ❌ | OPEN | `OPEN`, `FULL`, `CANCELLED`, `COMPLETED` | Trạng thái session |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

**Unique Index**: `{ host_id, booking_date, start_minutes }` where `status in [OPEN, FULL]` — Host chỉ có 1 session active tại cùng slot

---

### Model: MatchQueue

**File**: `src/models/match-queue.model.js` | **Collection**: `matchqueues`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `user_id` | ObjectId | ✅ | - | ref: User | Người vào hàng đợi |
| `sport_id` | ObjectId | ✅ | - | ref: Sport | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | ref: Facility | Cơ sở |
| `booking_date` | String | ✅ | - | YYYY-MM-DD | Ngày muốn chơi |
| `start_minutes` | Number | ✅ | - | - | Giờ bắt đầu mong muốn |
| `end_minutes` | Number | ✅ | - | - | Giờ kết thúc mong muốn |
| `group_size` | Number | ❌ | 2 | min: 2 | Số người cần ghép |
| `team_mode` | String | ❌ | INDIVIDUAL | `INDIVIDUAL`, `TEAM_FILL`, `TEAM_VS_TEAM` | Chế độ đội |
| `preferred_team` | String | ❌ | AUTO | `A`, `B`, `AUTO` | Đội ưu tiên |
| `member_count` | Number | ❌ | 1 | min: 1 | Số người trong nhóm này |
| `team_size` | Number | ❌ | null | min: 1 | Kích thước đội (cho TEAM mode) |
| `payment_policy` | String | ❌ | SPLIT_EQUALLY | `HOST_PAY_ALL`, `SPLIT_EQUALLY`, `TEAM_REPRESENTATIVES_SPLIT` | Chính sách chia tiền |
| `matching_session_id` | ObjectId | ❌ | null | ref: MatchingSession | Session được ghép vào |
| `claim_token` | String | ❌ | null | select: false | Token nội bộ (ẩn khỏi response) |
| `status` | String | ❌ | SEARCHING | `SEARCHING`, `MATCHED`, `CANCELLED`, `EXPIRED` | Trạng thái trong hàng đợi |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

### Model: FixedSchedule

**File**: `src/models/fixed-schedule.model.js` | **Collection**: `fixedschedules`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Diễn giải |
|-----------|------|---------|---------|------|-----------|
| `_id` | ObjectId | Auto | - | - | Primary key |
| `user_id` | ObjectId | ✅ | - | ref: User | Người tạo lịch |
| `type` | String | ✅ | - | `COURT_BOOKING`, `MATCHING` | Loại lịch cố định |
| `sport_id` | ObjectId | ✅ | - | ref: Sport | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | ref: Facility | Cơ sở |
| `court_id` | ObjectId | ✅ | - | ref: Court | Sân |
| `start_minutes` | Number | ✅ | - | - | Giờ bắt đầu mỗi buổi |
| `end_minutes` | Number | ✅ | - | - | Giờ kết thúc mỗi buổi |
| `frequency` | String | ✅ | - | `DAILY`, `WEEKLY` | Tần suất |
| `days_of_week` | [Number] | ❌ | [] | 0=CN, 1=T2...6=T7 | Các ngày trong tuần (nếu WEEKLY) |
| `start_date` | String | ✅ | - | YYYY-MM-DD | Ngày bắt đầu |
| `end_date` | String | ❌ | null | YYYY-MM-DD | Ngày kết thúc (null = vĩnh viễn) |
| `status` | String | ❌ | PENDING_APPROVAL | `PENDING_APPROVAL`, `ACTIVE`, `PAUSED`, `REJECTED`, `CANCELLED`, `EXPIRED` | Trạng thái lịch |
| `exception_dates[].date` | String | - | - | YYYY-MM-DD | Ngày ngoại lệ |
| `exception_dates[].type` | String | - | - | `CANCELLED`, `TEAM_UNAVAILABLE` | Loại ngoại lệ |
| `exception_dates[].reason` | String | - | '' | - | Lý do ngoại lệ |
| `paused_at` | Date | ❌ | null | - | Thời điểm tạm dừng |
| `matching_config` | Object | ❌ | null | - | Cấu hình ghép trận (nếu type=MATCHING) |
| `matching_config.team_mode` | String | - | - | `INDIVIDUAL`, `TEAM_FILL`, `TEAM_VS_TEAM` | Chế độ đội |
| `matching_config.team_size` | Number | - | - | min: 1 | Kích thước đội |
| `matching_config.payment_policy` | String | - | - | - | Chính sách chia tiền |
| `matching_config.readiness` | String | - | RECRUITING | `RECRUITING`, `READY` | Trạng thái sẵn sàng |
| `matching_config.members[]` | - | - | [] | - | Thành viên cố định (có status INVITED/APPROVED/LEFT) |
| `approved_by` | ObjectId | ❌ | null | ref: User | STAFF/ADMIN duyệt |
| `approved_at` | Date | ❌ | null | - | Thời điểm duyệt |
| `rejected_by` | ObjectId | ❌ | null | ref: User | STAFF/ADMIN từ chối |
| `rejected_at` / `rejection_reason` | Date/String | ❌ | null | - | Thông tin từ chối |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

### Model: Review

**File**: `src/models/review.model.js` | **Collection**: `reviews`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Diễn giải |
|-----------|------|---------|---------|-----------|
| `_id` | ObjectId | Auto | - | Primary key |
| `user_id` | ObjectId | ✅ | - | ref: User |
| `court_id` | ObjectId | ✅ | - | ref: Court |
| `rating` | Number | ✅ | - | min: 1, max: 5 |
| `comment` | String | ❌ | '' | Nhận xét |
| `created_at` / `updated_at` | Date | Auto | - | timestamps |

---

## 5.3 Quan hệ dữ liệu

| Quan hệ | Kiểu | Mô tả |
|---------|------|-------|
| User → Facility | N-1 | STAFF có `facility_id` → cơ sở quản lý |
| Facility ↔ User (staff) | 1-N | Facility có `staff_ids[]` |
| Facility → Court | 1-N | Mỗi facility có nhiều court |
| Sport → Court | 1-N | Mỗi court thuộc 1 môn thể thao |
| Court → Booking | 1-N | Một sân có nhiều booking |
| User → Booking | 1-N | Một user tạo nhiều booking |
| Booking → Payment | 1-1 | Mỗi booking có tối đa 1 payment active |
| FixedSchedule → Booking | 1-N | Lịch cố định sinh ra nhiều booking |
| User → FixedSchedule | 1-N | User tạo nhiều lịch cố định |
| User → MatchingSession (host) | 1-N | Host tạo nhiều session |
| MatchingSession → Booking | 1-1 | Session liên kết 1 booking |
| FixedSchedule → MatchingSession | 1-N | Lịch matching cố định sinh nhiều session theo ngày |
| User → Notification | 1-N | Mỗi user nhận nhiều thông báo |
| User → MatchQueue | 1-N | User có thể vào hàng đợi nhiều lần |
| MatchQueue → MatchingSession | N-1 | Nhiều queue entry cùng được ghép vào 1 session |
| Court → CourtBlock | 1-N | Sân có nhiều lần block |
| Facility → CourtBlock | 1-N | Cơ sở có nhiều lần block |
| User → Review | 1-N | User viết nhiều review |
| Court → Review | 1-N | Sân nhận nhiều review |

---

## 5.4 ERD — Mô tả để vẽ lại

### Danh sách Entity và thuộc tính key

| Entity | PK | FK chính | Loại quan hệ với entity khác |
|--------|----|---------|------------------------------|
| User | _id | facility_id → Facility | N-1 với Facility |
| Facility | _id | - | 1-N với Court, 1-N CourtBlock; N-N với User qua staff_ids |
| Sport | _id | - | 1-N với Court |
| Court | _id | facility_id, sport_id | N-1 Facility, N-1 Sport |
| CourtBlock | _id | facility_id, court_id, created_by | N-1 Facility, N-1 Court |
| Booking | _id | user_id, court_id, fixed_schedule_id | N-1 User, N-1 Court, N-1 FixedSchedule |
| Payment | _id | booking_id, user_id, refunded_by | 1-1 Booking, N-1 User |
| Notification | _id | userId | N-1 User |
| MatchingSession | _id | host_id, sport_id, facility_id, court_id, booking_id, fixed_schedule_id | N-1 nhiều entity |
| MatchQueue | _id | user_id, sport_id, facility_id, matching_session_id | N-1 nhiều entity |
| FixedSchedule | _id | user_id, sport_id, facility_id, court_id, approved_by, rejected_by | N-1 nhiều entity |
| Review | _id | user_id, court_id | N-1 User, N-1 Court |

### Ràng buộc nghiệp vụ quan trọng:
1. **Payment**: Unique partial index đảm bảo chỉ có 1 payment PENDING/SUCCESS cho mỗi booking
2. **Booking**: Không thể tạo 2 booking trùng `court_id + booking_date + time range` khi đang PENDING/CONFIRMED/COMPLETED
3. **FixedSchedule Booking**: Unique partial index cho `fixed_schedule_id + court_id + booking_date + start/end_minutes`
4. **MatchingSession**: Unique — host chỉ có 1 session OPEN/FULL trong cùng slot thời gian
5. **CourtBlock**: `start_time` phải trước `end_time` (pre-validate hook)
6. **User**: `email` unique, `firebaseUid` unique sparse (nullable)
