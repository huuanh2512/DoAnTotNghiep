# 5. THIẾT KẾ DỮ LIỆU VÀ ERD

## 5.1 Danh sách Model / Schema MongoDB

| Tên Model | Collection | Mục đích | File định nghĩa | Quan hệ chính |
|-----------|-----------|---------|----------------|---------------|
| User | users | Lưu thông tin tài khoản (CUSTOMER/STAFF/ADMIN) | `models/user.model.js` | Ref → Facility |
| Facility | facilities | Thông tin cơ sở thể thao | `models/facility.model.js` | staff_ids → User |
| Sport | sports | Môn thể thao (bóng đá, cầu lông...) | `models/sport.model.js` | Độc lập |
| Court | courts | Sân thi đấu, bao gồm slot_config | `models/court.model.js` | Ref → Facility, Sport |
| CourtBlock | court-blocks | Lịch khóa/bảo trì sân | `models/court-block.model.js` | Ref → Court, Facility |
| Booking | bookings | Lịch đặt sân | `models/booking.model.js` | Ref → Court, User, FixedSchedule |
| Payment | payments | Hóa đơn thanh toán | `models/payment.model.js` | Ref → Booking, User |
| FixedSchedule | fixedschedules | Lịch đặt sân định kỳ | `models/fixed-schedule.model.js` | Ref → User, Sport, Facility, Court |
| MatchingSession | matchingsessions | Phiên ghép đối thủ | `models/matching.model.js` | Ref → User, Sport, Facility, Court, Booking, FixedSchedule |
| MatchQueue | matchqueues | Hàng đợi ghép tự động | `models/match-queue.model.js` | Ref → User, Sport, Facility, MatchingSession |
| Notification | notifications | Thông báo hệ thống | `models/notification.model.js` | Ref → User |
| Review | reviews | Đánh giá dịch vụ | `models/review.model.js` | Ref → User, Booking (dự kiến) |

---

## 5.2 Chi tiết từng thực thể

### Model: User
**Collection:** `users` | **File:** `models/user.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Index | Ref | Mô tả nghiệp vụ |
|-----------|------|---------|----------|------|-------|-----|-----------------|
| `email` | String | ✅ | - | - | unique | - | Email đăng nhập, lowercase, unique |
| `password` | String | ✅ | - | - | - | - | Mật khẩu đã mã hóa bcrypt |
| `role` | String | - | CUSTOMER | CUSTOMER, STAFF, ADMIN | - | - | Vai trò xác định quyền hạn |
| `status` | String | - | PENDING_OTP | PENDING_OTP, ACTIVE, INACTIVE, BANNED | - | - | Trạng thái tài khoản |
| `profile.name` | String | - | '' | - | - | - | Tên hiển thị |
| `profile.phone` | String | - | '' | - | - | - | Số điện thoại |
| `profile.avatar_url` | String | - | '' | - | - | - | URL ảnh đại diện (Cloudinary) |
| `facility_id` | ObjectId | - | null | - | - | Facility | Cơ sở STAFF đang quản lý |
| `fcmTokens` | [String] | - | [] | - | - | - | Mảng FCM token thiết bị |
| `resetPasswordOtp` | String | - | null | - | - | - | OTP đặt lại mật khẩu |
| `resetPasswordOtpExpires` | Date | - | null | - | - | - | Thời gian hết hạn OTP |
| `created_at` | Date | auto | - | - | - | - | Thời điểm tạo |
| `updated_at` | Date | auto | - | - | - | - | Thời điểm cập nhật |

---

### Model: Facility
**Collection:** `facilities` | **File:** `models/facility.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Index | Ref | Mô tả |
|-----------|------|---------|----------|------|-------|-----|-------|
| `name` | String | ✅ | - | - | - | - | Tên cơ sở thể thao |
| `address.city` | String | - | '' | - | - | - | Thành phố |
| `address.full` | String | - | '' | - | - | - | Địa chỉ đầy đủ |
| `active` | Boolean | - | true | - | - | - | Trạng thái hoạt động |
| `staff_ids` | [ObjectId] | - | [] | - | - | User | Danh sách STAFF quản lý |

---

### Model: Sport
**Collection:** `sports` | **File:** `models/sport.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Mô tả |
|-----------|------|---------|----------|-------|
| `name` | String | ✅ | - | Tên môn thể thao (Bóng đá, Cầu lông...) |
| `active` | Boolean | - | true | Đang hoạt động hay không |

---

### Model: Court
**Collection:** `courts` | **File:** `models/court.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Ref | Mô tả |
|-----------|------|---------|----------|------|-----|-------|
| `name` | String | ✅ | - | - | - | Tên sân (Sân A, Sân 1...) |
| `facility_id` | ObjectId | ✅ | - | - | Facility | Thuộc cơ sở nào |
| `sport_id` | ObjectId | ✅ | - | - | Sport | Môn thể thao của sân |
| `code` | String | - | '' | - | - | Mã sân |
| `status` | String | - | ACTIVE | ACTIVE, INACTIVE, MAINTENANCE | - | Trạng thái sân |
| `price_per_hour` | Number | - | 0 | - | - | Giá thuê theo giờ (VND) |
| `slot_config.opening_minutes` | Number | - | 360 | - | - | Giờ mở cửa (phút từ 00:00, mặc định 6:00) |
| `slot_config.closing_minutes` | Number | - | 1320 | - | - | Giờ đóng cửa (phút từ 00:00, mặc định 22:00) |
| `slot_config.slot_duration_minutes` | Number | - | 60 | - | - | Độ dài mỗi slot (phút) |
| `slot_config.slots` | [courtSlot] | - | [] | - | - | Danh sách slot (slot_index, start_minutes, end_minutes, is_available, mode) |

---

### Model: Booking
**Collection:** `bookings` | **File:** `models/booking.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Index | Ref | Mô tả |
|-----------|------|---------|----------|------|-------|-----|-------|
| `user_id` | ObjectId | - | null | - | - | User | Người đặt (null nếu là khách vãng lai) |
| `guest_name` | String | - | null | - | - | - | Tên khách vãng lai |
| `guest_phone` | String | - | null | - | - | - | SĐT khách vãng lai |
| `court_id` | ObjectId | ✅ | - | - | - | Court | Sân được đặt |
| `booking_date` | String | ✅ | - | - | ✅ | - | Ngày đặt "YYYY-MM-DD" |
| `start_minutes` | Number | ✅ | - | - | ✅ | - | Giờ bắt đầu (phút từ 00:00) |
| `end_minutes` | Number | ✅ | - | - | - | - | Giờ kết thúc (phút từ 00:00) |
| `total_price` | Number | - | 0 | - | - | - | Tổng tiền (VND) |
| `status` | String | - | PENDING | PENDING, CONFIRMED, CANCELLED, COMPLETED | ✅ | - | Trạng thái booking |
| `fixed_schedule_id` | ObjectId | - | null | - | ✅ | FixedSchedule | Liên kết lịch cố định |
| `is_fixed_schedule` | Boolean | - | false | - | - | - | Có phải từ lịch cố định không |
| `cancel_reason` | String | - | null | - | - | - | Lý do hủy |
| `cancelled_by` | String | - | null | - | - | - | Ai hủy (userId hoặc 'system') |
| `cancelled_at` | Date | - | null | - | - | - | Thời điểm hủy |

**Index quan trọng:**
- `{ status: 1, booking_date: 1, start_minutes: 1 }` – Query booking theo ngày
- `{ fixed_schedule_id: 1, status: 1, booking_date: 1 }` – Query booking của lịch cố định
- Unique: `{ fixed_schedule_id, court_id, booking_date, start_minutes, end_minutes }` (chỉ áp dụng cho booking active)

---

### Model: Payment
**Collection:** `payments` | **File:** `models/payment.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Ref | Mô tả |
|-----------|------|---------|----------|------|-----|-------|
| `booking_id` | ObjectId | ✅ | - | - | Booking | Booking tương ứng |
| `user_id` | ObjectId | ✅ | - | - | User | Người thanh toán |
| `amount` | Number | ✅ | - | - | - | Số tiền (VND) |
| `method` | String | - | CASH | CASH, BANK_TRANSFER, MOMO, ZALOPAY, VNPAY | - | Phương thức thanh toán |
| `status` | String | - | PENDING | PENDING, SUCCESS, FAILED, CANCELLED, REFUND_PENDING, REFUNDED | - | Trạng thái hóa đơn |
| `transaction_id` | String | - | '' | - | - | Mã giao dịch từ ZaloPay |
| `refunded_at` | Date | - | null | - | - | Thời điểm hoàn tiền |
| `refunded_by` | ObjectId | - | null | - | User | Admin/Staff thực hiện hoàn tiền |
| `refund_reason` | String | - | null | - | - | Lý do hoàn tiền |

**Index quan trọng:**
- Unique: `{ booking_id: 1, user_id: 1 }` chỉ khi status PENDING hoặc SUCCESS → mỗi booking chỉ có 1 payment active

---

### Model: FixedSchedule
**Collection:** `fixedschedules` | **File:** `models/fixed-schedule.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Index | Ref | Mô tả |
|-----------|------|---------|----------|------|-------|-----|-------|
| `user_id` | ObjectId | ✅ | - | - | ✅ | User | Người đăng ký lịch |
| `type` | String | ✅ | - | COURT_BOOKING, MATCHING | ✅ | - | Loại lịch cố định |
| `sport_id` | ObjectId | ✅ | - | - | ✅ | Sport | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | - | ✅ | Facility | Cơ sở |
| `court_id` | ObjectId | ✅ | - | - | ✅ | Court | Sân |
| `start_minutes` | Number | ✅ | - | - | - | - | Giờ bắt đầu (phút từ 00:00) |
| `end_minutes` | Number | ✅ | - | - | - | - | Giờ kết thúc |
| `frequency` | String | ✅ | - | DAILY, WEEKLY | ✅ | - | Tần suất lặp |
| `days_of_week` | [Number] | - | [] | - | - | - | Ngày trong tuần (0=Sun, 6=Sat) |
| `start_date` | String | ✅ | - | - | - | - | Ngày bắt đầu "YYYY-MM-DD" |
| `end_date` | String | - | null | - | - | - | Ngày kết thúc (null = vô hạn) |
| `status` | String | - | PENDING_APPROVAL | PENDING_APPROVAL, ACTIVE, PAUSED, REJECTED, CANCELLED, EXPIRED | ✅ | - | Trạng thái lịch cố định |
| `exception_dates` | [ExceptionDate] | - | [] | - | - | - | Danh sách ngày ngoại lệ (type: CANCELLED/TEAM_UNAVAILABLE) |
| `paused_at` | Date | - | null | - | - | - | Thời điểm tạm dừng |
| `matching_config` | Object | - | null | - | - | - | Cấu hình ghép trận (chỉ khi type=MATCHING) |
| `approved_by` | ObjectId | - | null | - | - | User | Admin/Staff duyệt |
| `approved_at` | Date | - | null | - | - | - | Thời điểm duyệt |
| `rejected_by` | ObjectId | - | null | - | - | User | Admin/Staff từ chối |
| `rejection_reason` | String | - | null | - | - | - | Lý do từ chối |

---

### Model: MatchingSession
**Collection:** `matchingsessions` | **File:** `models/matching.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Mặc định | Enum | Index | Ref | Mô tả |
|-----------|------|---------|----------|------|-------|-----|-------|
| `host_id` | ObjectId | ✅ | - | - | ✅ | User | Người tạo phiên (chủ nhà) |
| `sport_id` | ObjectId | ✅ | - | - | ✅ | Sport | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | - | ✅ | Facility | Cơ sở |
| `court_id` | ObjectId | ✅ | - | - | - | Court | Sân |
| `booking_id` | ObjectId | - | null | - | - | Booking | Booking liên kết |
| `fixed_schedule_id` | ObjectId | - | null | - | ✅ | FixedSchedule | Lịch cố định liên kết |
| `booking_date` | String | ✅ | - | - | ✅ | - | Ngày chơi "YYYY-MM-DD" |
| `start_minutes` | Number | ✅ | - | - | - | - | Giờ bắt đầu |
| `end_minutes` | Number | ✅ | - | - | - | - | Giờ kết thúc |
| `total_players_needed` | Number | ✅ | - | - | - | - | Số người cần tuyển thêm |
| `team_mode` | String | - | INDIVIDUAL | INDIVIDUAL, TEAM_FILL, TEAM_VS_TEAM | - | - | Chế độ đội |
| `host_team_code` | String | - | A | A, B | - | - | Đội của host |
| `payment_policy` | String | - | HOST_PAY_ALL | HOST_PAY_ALL, SPLIT_EQUALLY, TEAM_REPRESENTATIVES_SPLIT | - | - | Chính sách thanh toán |
| `auto_approve` | Boolean | - | true | - | - | - | Tự động chấp nhận thành viên |
| `description` | String | - | '' | - | - | - | Mô tả phiên |
| `members` | [MatchingMember] | - | [] | - | - | - | Danh sách thành viên |
| `teams` | [MatchingTeam] | - | [] | - | - | - | Cấu hình đội |
| `status` | String | - | OPEN | OPEN, FULL, CANCELLED, COMPLETED | ✅ | - | Trạng thái phiên |

**MatchingMember (embedded):**
- `user_id`, `status` (PENDING/APPROVED/REJECTED), `team_code` (A/B), `represented_count`, `join_mode` (INDIVIDUAL/TEAM_REPRESENTATIVE), `team_name`, `note`, `joined_at`

---

### Model: MatchQueue
**Collection:** `matchqueues` | **File:** `models/match-queue.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Enum | Mô tả |
|-----------|------|---------|------|-------|
| `user_id` | ObjectId | ✅ | - | Người vào hàng chờ |
| `sport_id` | ObjectId | ✅ | - | Môn thể thao |
| `facility_id` | ObjectId | ✅ | - | Cơ sở |
| `booking_date` | String | ✅ | - | Ngày chơi |
| `start_minutes`, `end_minutes` | Number | ✅ | - | Khung giờ |
| `group_size` | Number | - | - | Số người cần để tạo trận |
| `team_mode` | String | - | INDIVIDUAL, TEAM_FILL, TEAM_VS_TEAM | Chế độ đội |
| `preferred_team` | String | - | A, B, AUTO | Đội muốn gia nhập |
| `member_count` | Number | - | - | Số người đại diện |
| `payment_policy` | String | - | HOST_PAY_ALL, SPLIT_EQUALLY, TEAM_REPRESENTATIVES_SPLIT | Chính sách thanh toán |
| `matching_session_id` | ObjectId | - | - | Session đã ghép vào |
| `status` | String | - | SEARCHING, MATCHED, CANCELLED, EXPIRED | Trạng thái trong queue |

---

### Model: Notification
**Collection:** `notifications` | **File:** `models/notification.model.js`

| Thuộc tính | Kiểu | Bắt buộc | Enum | Index | Mô tả |
|-----------|------|---------|------|-------|-------|
| `userId` | ObjectId | ✅ | - | ✅ | Người nhận thông báo |
| `title` | String | ✅ | - | - | Tiêu đề thông báo |
| `content` | String | ✅ | - | - | Nội dung |
| `type` | String | - | BOOKING, PAYMENT, SYSTEM, PROMOTION | - | Loại thông báo |
| `audience` | String | - | CUSTOMER, STAFF, ADMIN, ALL | ✅ | Đối tượng nhận |
| `metadata.bookingId` | String | - | - | - | Link đến booking |
| `metadata.paymentId` | String | - | - | - | Link đến payment |
| `metadata.matchingSessionId` | String | - | - | - | Link đến session |
| `metadata.link` | String | - | - | - | Deep link |
| `isRead` | Boolean | - | false | - | Trạng thái đọc |

**Compound Index:** `{ userId: 1, audience: 1, isRead: 1, createdAt: -1 }` – Query nhanh thông báo chưa đọc

---

## 5.3 Quan hệ dữ liệu

| Quan hệ | Kiểu | Mô tả |
|---------|------|-------|
| User → Booking | 1-N | Một user có nhiều booking |
| User → Payment | 1-N | Một user có nhiều payment |
| User → MatchingSession (host) | 1-N | Một user có thể host nhiều session |
| User → Notification | 1-N | Một user nhận nhiều thông báo |
| User → FixedSchedule | 1-N | Một user đăng ký nhiều lịch cố định |
| Facility → Court | 1-N | Một cơ sở có nhiều sân |
| Facility → User (staff) | N-N | Một cơ sở có nhiều staff (qua staff_ids) |
| Sport → Court | 1-N | Một môn thể thao có nhiều sân |
| Court → Booking | 1-N | Một sân có nhiều booking |
| Booking → Payment | 1-1 | Mỗi booking có một payment active |
| FixedSchedule → Booking | 1-N | Một lịch cố định sinh nhiều booking |
| FixedSchedule → MatchingSession | 1-N | Một lịch cố định sinh nhiều phiên ghép trận |
| MatchingSession → Booking | 1-1 | Phiên ghép trận liên kết booking |
| MatchQueue → MatchingSession | N-1 | Nhiều queue entry ghép vào một session |

---

## 5.4 ERD – Mô tả để vẽ lại

### Danh sách Entity và Primary Key

| Entity | Primary Key | Ghi chú |
|--------|-------------|---------|
| User | `_id` (ObjectId) | - |
| Facility | `_id` (ObjectId) | - |
| Sport | `_id` (ObjectId) | - |
| Court | `_id` (ObjectId) | - |
| CourtBlock | `_id` (ObjectId) | - |
| Booking | `_id` (ObjectId) | - |
| Payment | `_id` (ObjectId) | - |
| FixedSchedule | `_id` (ObjectId) | - |
| MatchingSession | `_id` (ObjectId) | - |
| MatchQueue | `_id` (ObjectId) | - |
| Notification | `_id` (ObjectId) | - |
| Review | `_id` (ObjectId) | - |

### Foreign Key / Ref và kiểu quan hệ

| Từ (Entity.field) | Đến | Kiểu | Ghi chú |
|-------------------|-----|------|---------|
| Court.facility_id | Facility | N-1 | Sân thuộc cơ sở |
| Court.sport_id | Sport | N-1 | Sân dành cho môn |
| User.facility_id | Facility | N-1 | STAFF gắn với cơ sở |
| Facility.staff_ids[] | User | N-N | Cơ sở có nhiều nhân viên |
| Booking.court_id | Court | N-1 | Booking thuộc sân |
| Booking.user_id | User | N-1 | Booking của user |
| Booking.fixed_schedule_id | FixedSchedule | N-1 | Null nếu booking thông thường |
| Payment.booking_id | Booking | 1-1 | Hóa đơn của booking |
| Payment.user_id | User | N-1 | User thanh toán |
| FixedSchedule.user_id | User | N-1 | User đăng ký lịch |
| FixedSchedule.court_id | Court | N-1 | Sân trong lịch cố định |
| FixedSchedule.sport_id | Sport | N-1 | Môn thể thao |
| FixedSchedule.facility_id | Facility | N-1 | Cơ sở |
| FixedSchedule.approved_by | User | N-1 | Admin/Staff duyệt |
| MatchingSession.host_id | User | N-1 | Host của session |
| MatchingSession.booking_id | Booking | 1-1 | Booking liên kết |
| MatchingSession.sport_id | Sport | N-1 | Môn thể thao |
| MatchingSession.facility_id | Facility | N-1 | Cơ sở |
| MatchingSession.court_id | Court | N-1 | Sân |
| MatchingSession.fixed_schedule_id | FixedSchedule | N-1 | Lịch cố định (nếu có) |
| MatchingSession.members[].user_id | User | N-N (embedded) | Thành viên phiên |
| MatchQueue.user_id | User | N-1 | User trong hàng chờ |
| MatchQueue.sport_id | Sport | N-1 | Môn thể thao |
| MatchQueue.facility_id | Facility | N-1 | Cơ sở |
| MatchQueue.matching_session_id | MatchingSession | N-1 | Session sau khi ghép |
| Notification.userId | User | N-1 | User nhận thông báo |
| CourtBlock.court_id | Court | N-1 | Sân bị khóa |

### Ràng buộc nghiệp vụ quan trọng
1. Booking không được trùng (court_id + booking_date + start/end_minutes + status ACTIVE) → unique index
2. FixedSchedule sinh booking không trùng → unique index (fixed_schedule_id + court_id + booking_date + start/end)
3. MatchingSession: host không được có 2 session OPEN/FULL cùng giờ → unique index
4. Payment: mỗi booking chỉ có 1 payment PENDING hoặc SUCCESS → unique index
5. User.email là unique → không trùng email
