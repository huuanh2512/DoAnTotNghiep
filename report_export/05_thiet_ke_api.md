# 6. THIẾT KẾ API

## 6.1 Danh sách Route/API

**Base URL**: `/api/v1`  
**Authentication**: Bearer Token (JWT) cho hầu hết API, trừ routes public

---

### Nhóm: Auth (`/api/v1/auth`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/auth/register` | ❌ | - | `auth.controller.js::register` | Đăng ký tài khoản |
| POST | `/auth/verify-email` | ❌ | - | `auth.controller.js::verifyEmail` | Xác thực OTP email |
| POST | `/auth/resend-verification` | ❌ | - | `auth.controller.js::resendVerification` | Gửi lại OTP |
| POST | `/auth/sign-in` | ❌ | - | `auth.controller.js::signIn` | Đăng nhập email/password |
| POST | `/auth/firebase/register` | ❌ | - | `auth.controller.js::firebaseRegister` | Đăng ký qua Firebase |
| POST | `/auth/firebase/login` | ❌ | - | `auth.controller.js::firebaseLogin` | Đăng nhập Firebase |
| POST | `/auth/firebase/refresh` | ❌ | - | `auth.controller.js::firebaseLogin` | Refresh via Firebase |
| POST | `/auth/firebase/complete-email-verification` | ❌ | - | `auth.controller.js::firebaseCompleteEmailVerification` | Hoàn thành xác thực Firebase |
| POST | `/auth/refresh-token` | ❌ | - | `auth.controller.js::refreshToken` | Làm mới Access Token |
| POST | `/auth/sign-out` | ❌ | - | `auth.controller.js::signOut` | Đăng xuất |
| POST | `/auth/forgot-password` | ❌ | - | `auth.controller.js::forgotPassword` | Quên mật khẩu (gửi OTP) |
| POST | `/auth/reset-password` | ❌ | - | `auth.controller.js::resetPassword` | Đặt lại mật khẩu |
| POST | `/auth/change-password` | ✅ | ALL | `auth.controller.js::changePassword` | Đổi mật khẩu khi đã login |

---

### Nhóm: User (`/api/v1/user`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/user` | ✅ | ADMIN | `user.controller.js::queryUsers` | Danh sách user |
| GET | `/user/:id` | ✅ | ALL | `user.controller.js::getUserProfile` | Xem hồ sơ |
| PUT | `/user/:id` | ✅ | ALL | `user.controller.js::updateUserProfile` | Cập nhật hồ sơ |
| PUT | `/user/:id/role` | ✅ | ADMIN | `user.controller.js::updateUserRole` | Thay đổi role |
| PUT | `/user/:id/status` | ✅ | ADMIN | `user.controller.js::updateUserStatus` | Thay đổi status |
| POST | `/user/:id/assign-facility` | ✅ | ADMIN | `user.controller.js::assignUserFacility` | Gán cơ sở cho staff |
| POST | `/user/register-fcm` | ✅ | ALL | `fcm.controller.js::registerFCMToken` | Đăng ký FCM token |
| POST | `/user/remove-fcm` | ✅ | ALL | `fcm.controller.js::removeFCMToken` | Xóa FCM token |
| POST | `/user/provision-firebase` | ✅ | ADMIN | `user.controller.js::provisionFirebaseUser` | Tạo Firebase user |

---

### Nhóm: Facility (`/api/v1/facility`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/facility` | ✅ | ALL | `facility.controller.js::queryFacilities` | Danh sách cơ sở |
| GET | `/facility/:id` | ✅ | ALL | `facility.controller.js::getFacilityById` | Chi tiết cơ sở |
| POST | `/facility` | ✅ | ADMIN | `facility.controller.js::createFacility` | Tạo cơ sở |
| PUT | `/facility/:id` | ✅ | ADMIN, STAFF | `facility.controller.js::updateFacility` | Cập nhật cơ sở |
| DELETE | `/facility/:id` | ✅ | ADMIN | `facility.controller.js::deleteFacility` | Xóa cơ sở |

---

### Nhóm: Sport (`/api/v1/sport`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/sport` | ✅ | ALL | `sport.controller.js::querySports` | Danh sách môn thể thao |
| POST | `/sport` | ✅ | ADMIN | `sport.controller.js::createSport` | Tạo môn |
| PUT | `/sport/:id` | ✅ | ADMIN | `sport.controller.js::updateSport` | Cập nhật môn |
| DELETE | `/sport/:id` | ✅ | ADMIN | `sport.controller.js::deleteSport` | Xóa môn |

---

### Nhóm: Court (`/api/v1/court`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/court` | ✅ | ALL | `court.controller.js::queryCourts` | Danh sách sân |
| POST | `/court` | ✅ | ADMIN, STAFF | `court.controller.js::createCourt` | Tạo sân |
| PUT | `/court/:id` | ✅ | ADMIN, STAFF | `court.controller.js::updateCourt` | Cập nhật sân |
| DELETE | `/court/:id` | ✅ | ADMIN, STAFF | `court.controller.js::deleteCourt` | Xóa sân |
| GET | `/court/:id/slot-config` | ✅ | ALL | `court.controller.js::getCourtSlotConfig` | Lấy cấu hình slot |
| PUT | `/court/:id/slot-config` | ✅ | ADMIN, STAFF | `court.controller.js::upsertCourtSlotConfig` | Cập nhật slot config |

---

### Nhóm: Court Blocks (`/api/v1/court-blocks`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/court-blocks` | ✅ | ALL | `court-blocks.controller.js::queryCourtBlocks` | Danh sách block |
| POST | `/court-blocks` | ✅ | ADMIN, STAFF | `court-blocks.controller.js::createCourtBlock` | Tạo block |
| DELETE | `/court-blocks/:id` | ✅ | ADMIN, STAFF | `court-blocks.controller.js::deleteCourtBlock` | Xóa block |

---

### Nhóm: Booking (`/api/v1/booking`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/booking` | ✅ | ALL | `booking.controller.js::createBooking` | Tạo booking |
| GET | `/booking` | ✅ | ALL | `booking.controller.js::queryBookings` | Danh sách booking |
| GET | `/booking/:id` | ✅ | ALL | `booking.controller.js::getBookingDetail` | Chi tiết booking |
| PUT | `/booking/:id` | ✅ | ALL | `booking.controller.js::updateBooking` | Cập nhật booking |
| PUT | `/booking/:id/cancel` | ✅ | ALL | `booking.controller.js::cancelBooking` | Hủy booking |
| PUT | `/booking/:id/status` | ✅ | ADMIN, STAFF | `booking.controller.js::updateBookingStatus` | Đổi trạng thái |

---

### Nhóm: Payment (`/api/v1/payment`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/payment` | ✅ | ALL | `payment.controller.js::queryPayments` | Danh sách payment |
| POST | `/payment` | ✅ | ALL | `payment.controller.js::createPayment` | Tạo payment |
| PUT | `/payment/:id/status` | ✅ | ALL | `payment.controller.js::updatePaymentStatus` | Cập nhật trạng thái |

---

### Nhóm: ZaloPay (`/api/v1/zalopay`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/zalopay/callback` | ❌ (HMAC) | - | `zalopay.controller.js::handleCallback` | ZaloPay server callback |
| POST | `/zalopay/create-order` | ✅ | ALL | `zalopay.controller.js::createOrder` | Tạo đơn ZaloPay |
| POST | `/zalopay/query` | ✅ | ALL | `zalopay.controller.js::queryOrder` | Truy vấn trạng thái |

---

### Nhóm: Notification (`/api/v1/notification`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/notification` | ✅ | ALL | `notification.controller.js::queryNotifications` | Danh sách thông báo |
| PUT | `/notification/:id/read` | ✅ | ALL | `notification.controller.js::markAsRead` | Đánh dấu đã đọc |

---

### Nhóm: Matching (`/api/v1/matching`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/matching/queue/join` | ✅ | CUSTOMER | `matching.controller.js::joinQueue` | Vào hàng đợi auto match |
| POST | `/matching/queue/leave` | ✅ | CUSTOMER | `matching.controller.js::leaveQueue` | Rời hàng đợi |
| GET | `/matching/queue/status` | ✅ | CUSTOMER | `matching.controller.js::getQueueStatus` | Trạng thái hàng đợi |
| POST | `/matching` | ✅ | CUSTOMER | `matching.controller.js::createSession` | Tạo phòng ghép trận |
| GET | `/matching` | ✅ | ALL | `matching.controller.js::querySessions` | Danh sách session |
| GET | `/matching/:id` | ✅ | ALL | `matching.controller.js::getSessionDetail` | Chi tiết session |
| POST | `/matching/:id/join` | ✅ | CUSTOMER | `matching.controller.js::joinSession` | Tham gia session |
| POST | `/matching/:id/leave` | ✅ | CUSTOMER | `matching.controller.js::leaveSession` | Rời session |
| PUT | `/matching/:id/members/:userId` | ✅ | CUSTOMER | `matching.controller.js::updateMemberStatus` | Duyệt/từ chối member |
| PUT | `/matching/:id/status` | ✅ | CUSTOMER | `matching.controller.js::updateSessionStatus` | Cập nhật trạng thái session |

---

### Nhóm: Fixed Schedule (`/api/v1/fixed-schedule`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/fixed-schedule` | ✅ | ALL | `fixed-schedule.controller.js::createFixedSchedule` | Tạo lịch cố định |
| GET | `/fixed-schedule` | ✅ | ALL | `fixed-schedule.controller.js::queryFixedSchedules` | Danh sách lịch |
| PUT | `/fixed-schedule/:id/approve` | ✅ | ADMIN, STAFF | `fixed-schedule.controller.js::approveFixedSchedule` | Duyệt |
| PUT | `/fixed-schedule/:id/reject` | ✅ | ADMIN, STAFF | `fixed-schedule.controller.js::rejectFixedSchedule` | Từ chối |
| PUT | `/fixed-schedule/:id/pause` | ✅ | ADMIN, STAFF | `fixed-schedule.controller.js::pauseFixedSchedule` | Tạm dừng |
| PUT | `/fixed-schedule/:id/resume` | ✅ | ADMIN, STAFF | `fixed-schedule.controller.js::resumeFixedSchedule` | Tiếp tục |
| PUT | `/fixed-schedule/:id/cancel` | ✅ | ALL | `fixed-schedule.controller.js::cancelFixedSchedule` | Hủy cả chuỗi |
| POST | `/fixed-schedule/:id/matching/join` | ✅ | CUSTOMER | `fixed-schedule.controller.js::joinFixedMatchingSchedule` | Join lịch matching cố định |
| POST | `/fixed-schedule/:id/matching/leave` | ✅ | CUSTOMER | `fixed-schedule.controller.js::leaveFixedMatchingSchedule` | Leave lịch matching cố định |
| POST | `/fixed-schedule/:id/occurrences/:date/cancel` | ✅ | ALL | `fixed-schedule.controller.js::cancelFixedMatchingOccurrence` | Hủy một buổi |

---

### Nhóm: Reports (`/api/v1/reports`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/reports/court-performance` | ✅ | ADMIN, STAFF | `reports.controller.js::getCourtPerformance` | Báo cáo hiệu suất sân |
| GET | `/reports/advanced-performance` | ✅ | ADMIN | `reports.controller.js::getAdvancedPerformance` | Báo cáo nâng cao |

---

### Nhóm: Review (`/api/v1/review`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| GET | `/review` | ✅ | ALL | `review.controller.js::queryReviews` | Danh sách review |
| POST | `/review` | ✅ | CUSTOMER | `review.controller.js::createReview` | Tạo review |
| PUT | `/review/:id` | ✅ | CUSTOMER | `review.controller.js::updateReview` | Cập nhật review |
| DELETE | `/review/:id` | ✅ | CUSTOMER, ADMIN | `review.controller.js::deleteReview` | Xóa review |

---

### Nhóm: Upload (`/api/v1/upload`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|----------|------|------|-----------|-------|
| POST | `/upload/image` | ✅ | ALL | `upload.controller.js::uploadImage` | Upload ảnh lên Cloudinary |

---

### Health Check

| Method | Endpoint | Auth | Mô tả |
|--------|----------|------|-------|
| GET | `/health` | ❌ | Server status check |
| GET | `/health/cron` | ❌ | Cron jobs status |
| GET | `/api/v1/health` | ❌ | API health check |
| GET | `/api/v1/tracker` | ❌ | API tracker UI (dev tool) |
| GET | `/api/v1/export` | ❌ | Export API list as Markdown |

---

## 6.2 API Quan trọng — Mô tả chi tiết

---

### API 1: Đăng nhập

**Endpoint**: `POST /api/v1/auth/sign-in`  
**Mục đích**: Xác thực người dùng, trả về JWT tokens  
**Header/Auth**: Không cần Authorization  
**File code**: `src/controllers/auth.controller.js::signIn()` → `src/services/user-auth.service.js::signIn()`

**Request Body**:
```json
{
  "email": "customer@example.com",
  "password": "Password123!"
}
```

**Response thành công (200)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "_id": "6507f1f77bcf86cd799439011",
      "email": "customer@example.com",
      "role": "CUSTOMER",
      "status": "ACTIVE",
      "profile": {
        "name": "Nguyễn Văn A",
        "phone": "0901234567",
        "avatar_url": "https://res.cloudinary.com/..."
      }
    }
  }
}
```

**Lỗi thường gặp**:
- `401 INVALID_CREDENTIALS` — Email hoặc mật khẩu sai
- `403 ACCOUNT_BANNED` — Tài khoản bị khóa
- `403 EMAIL_NOT_VERIFIED` — Chưa xác thực email

---

### API 2: Đăng ký tài khoản

**Endpoint**: `POST /api/v1/auth/register`  
**Mục đích**: Tạo tài khoản mới, gửi OTP xác thực email  
**File code**: `src/controllers/auth.controller.js::register()`

**Request Body**:
```json
{
  "email": "newuser@example.com",
  "password": "Password123!",
  "name": "Nguyễn Văn B"
}
```

**Response (201)**:
```json
{
  "success": true,
  "message": "Đăng ký thành công. Vui lòng kiểm tra email để xác thực OTP.",
  "data": { "userId": "..." }
}
```

---

### API 3: Tạo Booking

**Endpoint**: `POST /api/v1/booking`  
**Auth**: Bearer Token  
**File code**: `src/controllers/booking.controller.js::createBooking()` → `src/services/booking.service.js`

**Request Body (Booking thường)**:
```json
{
  "court_id": "6507f1f77bcf86cd799439012",
  "booking_date": "2024-12-25",
  "start_minutes": 540,
  "end_minutes": 600
}
```

**Request Body (Lịch cố định - khi bật fixed schedule mode)**:
```json
{
  "court_id": "6507f1f77bcf86cd799439012",
  "booking_date": "2024-12-01",
  "start_minutes": 540,
  "end_minutes": 600,
  "is_fixed_schedule": true,
  "fixed_schedule": {
    "frequency": "WEEKLY",
    "days_of_week": [1, 3, 5],
    "start_date": "2024-12-01",
    "end_date": "2025-03-01"
  }
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "booking": {
      "_id": "...",
      "court_id": "...",
      "booking_date": "2024-12-25",
      "start_minutes": 540,
      "end_minutes": 600,
      "total_price": 150000,
      "status": "PENDING"
    },
    "payment": {
      "_id": "...",
      "amount": 150000,
      "method": "CASH",
      "status": "PENDING"
    }
  }
}
```

**Lỗi**:
- `404 COURT_NOT_FOUND` — Sân không tồn tại
- `400 COURT_INACTIVE` — Sân không hoạt động
- `409 SLOT_CONFLICT` — Trùng lịch

---

### API 4: Duyệt Booking

**Endpoint**: `PUT /api/v1/booking/:id/status`  
**Auth**: Bearer Token (STAFF hoặc ADMIN)  
**File code**: `src/controllers/booking.controller.js::updateBookingStatus()`

**Request Body**:
```json
{
  "status": "CONFIRMED"
}
```

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "status": "CONFIRMED",
    "updated_at": "2024-12-20T10:30:00Z"
  }
}
```

---

### API 5: Hủy Booking

**Endpoint**: `PUT /api/v1/booking/:id/cancel`  
**Auth**: Bearer Token (CUSTOMER owner hoặc STAFF/ADMIN)  
**File code**: `src/controllers/booking.controller.js::cancelBooking()`

**Request Body**:
```json
{
  "cancel_reason": "Bận việc đột xuất"
}
```

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "status": "CANCELLED",
    "cancel_reason": "Bận việc đột xuất",
    "cancelled_by": "user_id_here",
    "cancelled_at": "2024-12-20T09:00:00Z"
  }
}
```

---

### API 6: Tạo Payment

**Endpoint**: `POST /api/v1/payment`  
**Auth**: Bearer Token  
**File code**: `src/controllers/payment.controller.js::createPayment()`

**Request Body**:
```json
{
  "booking_id": "...",
  "method": "ZALOPAY"
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "booking_id": "...",
    "amount": 150000,
    "method": "ZALOPAY",
    "status": "PENDING"
  }
}
```

---

### API 7: Tạo Phòng Ghép Trận

**Endpoint**: `POST /api/v1/matching`  
**Auth**: Bearer Token (CUSTOMER)  
**File code**: `src/controllers/matching.controller.js::createSession()`

**Request Body**:
```json
{
  "booking_id": "...",
  "sport_id": "...",
  "facility_id": "...",
  "court_id": "...",
  "booking_date": "2024-12-25",
  "start_minutes": 540,
  "end_minutes": 600,
  "total_players_needed": 4,
  "team_mode": "TEAM_VS_TEAM",
  "description": "Tìm đội bóng đá 5 người để thi đấu giao hữu",
  "auto_approve": true,
  "payment_policy": "SPLIT_EQUALLY"
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "host_id": "...",
    "status": "OPEN",
    "total_players_needed": 4,
    "members": [
      { "user_id": "host_id", "status": "APPROVED", "team_code": "A" }
    ]
  }
}
```

---

### API 8: Tham Gia Phòng Ghép Trận

**Endpoint**: `POST /api/v1/matching/:id/join`  
**Auth**: Bearer Token (CUSTOMER)  
**File code**: `src/controllers/matching.controller.js::joinSession()`

**Request Body**:
```json
{
  "join_mode": "INDIVIDUAL",
  "team_code": "B",
  "represented_count": 1,
  "note": "Mình chơi thủ môn"
}
```

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "status": "OPEN",
    "members": [
      { "user_id": "host_id", "status": "APPROVED", "team_code": "A" },
      { "user_id": "joiner_id", "status": "APPROVED", "team_code": "B", "note": "Mình chơi thủ môn" }
    ]
  }
}
```

---

### API 9: Tạo Lịch Cố Định

**Endpoint**: `POST /api/v1/fixed-schedule`  
**Auth**: Bearer Token  
**File code**: `src/controllers/fixed-schedule.controller.js::createFixedSchedule()`

**Request Body**:
```json
{
  "type": "COURT_BOOKING",
  "sport_id": "...",
  "facility_id": "...",
  "court_id": "...",
  "start_minutes": 480,
  "end_minutes": 600,
  "frequency": "WEEKLY",
  "days_of_week": [2, 4, 6],
  "start_date": "2024-12-01",
  "end_date": "2025-06-30"
}
```

**Response (201)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "status": "PENDING_APPROVAL",
    "frequency": "WEEKLY",
    "days_of_week": [2, 4, 6]
  }
}
```

---

### API 10: Duyệt Lịch Cố Định

**Endpoint**: `PUT /api/v1/fixed-schedule/:id/approve`  
**Auth**: Bearer Token (STAFF hoặc ADMIN)  
**File code**: `src/controllers/fixed-schedule.controller.js::approveFixedSchedule()`

**Request Body**: `{}` (không cần body)  

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "status": "ACTIVE",
    "approved_by": "staff_user_id",
    "approved_at": "2024-12-20T08:00:00Z"
  }
}
```

---

### API 11: Báo cáo Hiệu Suất Sân

**Endpoint**: `GET /api/v1/reports/court-performance`  
**Auth**: Bearer Token (STAFF hoặc ADMIN)  
**Query Params**:
- `facility_id` (optional) — Lọc theo cơ sở
- `from` — Ngày bắt đầu (YYYY-MM-DD)
- `to` — Ngày kết thúc (YYYY-MM-DD)

**Response (200)**:
```json
{
  "success": true,
  "data": {
    "courts": [
      {
        "court_id": "...",
        "court_name": "Sân 1",
        "booking_count": 45,
        "revenue": 6750000,
        "utilization_rate": 0.75,
        "cancelled_count": 3
      }
    ],
    "summary": {
      "total_revenue": 15000000,
      "total_bookings": 100,
      "average_utilization": 0.68
    }
  }
}
```

---

### API 12: Health Check

**Endpoint**: `GET /health`  
**Auth**: Không cần  

**Response (200)**:
```json
{
  "status": "ok",
  "message": "Server is running",
  "service": "sport-energy-backend",
  "uptime": 3600.5,
  "timestamp": "2024-12-20T10:30:00Z"
}
```

**Endpoint Cron Health**: `GET /health/cron`  

**Response (200)**:
```json
{
  "status": "ok",
  "timestamp": "2024-12-20T10:30:00Z",
  "cron": {
    "autoCancelBookings": {
      "schedule": "*/1 * * * *",
      "lastRun": { "startedAt": "...", "status": "success", "summary": {...} }
    },
    "fixedScheduler": {
      "schedule": "5 0 * * *",
      "lastRun": { "startedAt": "...", "status": "success" }
    }
  }
}
```
