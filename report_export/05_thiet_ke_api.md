# 6. THIẾT KẾ API

## 6.1 Danh sách Route / API Backend

### Nhóm Auth (`/api/v1/auth`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/auth/register` | Không | - | `auth.controller.register` | Đăng ký tài khoản mới |
| POST | `/api/v1/auth/sign-in` | Không | - | `auth.controller.signIn` | Đăng nhập |
| POST | `/api/v1/auth/refresh-token` | Không | - | `auth.controller.refreshToken` | Làm mới Access Token |
| POST | `/api/v1/auth/sign-out` | Không | - | `auth.controller.signOut` | Đăng xuất |
| POST | `/api/v1/auth/forgot-password` | Không | - | `auth.controller.forgotPassword` | Gửi OTP quên mật khẩu |
| POST | `/api/v1/auth/reset-password` | Không | - | `auth.controller.resetPassword` | Đặt lại mật khẩu bằng OTP |
| POST | `/api/v1/auth/change-password` | JWT | ALL | `auth.controller.changePassword` | Đổi mật khẩu |

---

### Nhóm User (`/api/v1/user`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/user/:id` | JWT | ALL | `user.controller.getUserProfile` | Xem hồ sơ người dùng |
| PUT | `/api/v1/user/:id` | JWT | ALL | `user.controller.updateUserProfile` | Cập nhật hồ sơ |
| POST | `/api/v1/user/register-fcm` | JWT | ALL | `fcm.controller.registerFCMToken` | Đăng ký FCM Token |
| POST | `/api/v1/user/remove-fcm` | JWT | ALL | `fcm.controller.removeFCMToken` | Xóa FCM Token |
| GET | `/api/v1/user` | JWT | ADMIN | `user.controller.queryUsers` | Lấy danh sách user |
| PUT | `/api/v1/user/:id/role` | JWT | ADMIN | `user.controller.updateUserRole` | Cập nhật role user |
| PUT | `/api/v1/user/:id/status` | JWT | ADMIN | `user.controller.updateUserStatus` | Khóa/mở tài khoản |
| POST | `/api/v1/user/:id/assign-facility` | JWT | ADMIN | `user.controller.assignUserFacility` | Gán STAFF vào cơ sở |

---

### Nhóm Facility (`/api/v1/facility`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/facility` | JWT | ALL | `facility.controller.queryFacilities` | Danh sách cơ sở |
| GET | `/api/v1/facility/:id` | JWT | ALL | `facility.controller.getFacilityById` | Chi tiết cơ sở |
| POST | `/api/v1/facility` | JWT | ADMIN | `facility.controller.createFacility` | Tạo cơ sở mới |
| PUT | `/api/v1/facility/:id` | JWT | ADMIN, STAFF | `facility.controller.updateFacility` | Cập nhật cơ sở |
| DELETE | `/api/v1/facility/:id` | JWT | ADMIN | `facility.controller.deleteFacility` | Xóa cơ sở |

---

### Nhóm Sport (`/api/v1/sport`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/sport` | JWT | ALL | `sport.controller.querySports` | Danh sách môn thể thao |
| POST | `/api/v1/sport` | JWT | ADMIN, STAFF | `sport.controller.createSport` | Tạo môn thể thao |
| PUT | `/api/v1/sport/:id` | JWT | ADMIN, STAFF | `sport.controller.updateSport` | Cập nhật môn |
| DELETE | `/api/v1/sport/:id` | JWT | ADMIN, STAFF | `sport.controller.deleteSport` | Xóa môn |

---

### Nhóm Court (`/api/v1/court`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/court` | JWT | ALL | `court.controller.queryCourts` | Danh sách sân (filter by facility, sport) |
| POST | `/api/v1/court` | JWT | ADMIN, STAFF | `court.controller.createCourt` | Tạo sân mới |
| PUT | `/api/v1/court/:id` | JWT | ADMIN, STAFF | `court.controller.updateCourt` | Cập nhật thông tin sân |
| DELETE | `/api/v1/court/:id` | JWT | ADMIN, STAFF | `court.controller.deleteCourt` | Xóa sân |
| GET | `/api/v1/court/:id/slot-config` | JWT | ALL | `court.controller.getCourtSlotConfig` | Xem cấu hình slot giờ |
| PUT | `/api/v1/court/:id/slot-config` | JWT | ADMIN, STAFF | `court.controller.upsertCourtSlotConfig` | Thiết lập slot giờ |

---

### Nhóm Court Block (`/api/v1/court-blocks`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/court-blocks` | JWT | STAFF, ADMIN | `court-blocks.controller.createCourtBlock` | Tạo lịch khóa/bảo trì sân |
| GET | `/api/v1/court-blocks` | JWT | STAFF, ADMIN | `court-blocks.controller.queryCourtBlocks` | Danh sách khóa sân |
| PATCH | `/api/v1/court-blocks/:id` | JWT | STAFF, ADMIN | `court-blocks.controller.updateCourtBlock` | Cập nhật khóa sân |
| DELETE | `/api/v1/court-blocks/:id` | JWT | STAFF, ADMIN | `court-blocks.controller.cancelCourtBlock` | Hủy khóa sân |

---

### Nhóm Booking (`/api/v1/booking`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/booking` | JWT | ALL | `booking.controller.createBooking` | Tạo booking mới |
| GET | `/api/v1/booking` | JWT | ALL | `booking.controller.queryBookings` | Danh sách booking (filter đa dạng) |
| GET | `/api/v1/booking/:id` | JWT | ALL | `booking.controller.getBookingDetail` | Chi tiết booking |
| PUT | `/api/v1/booking/:id/cancel` | JWT | ALL | `booking.controller.cancelBooking` | Hủy booking |
| PUT | `/api/v1/booking/:id/status` | JWT | ADMIN, STAFF | `booking.controller.updateBookingStatus` | Duyệt/cập nhật trạng thái |

---

### Nhóm Payment (`/api/v1/payment`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/payment` | JWT | ALL | `payment.controller.queryPayments` | Danh sách hóa đơn |
| POST | `/api/v1/payment` | JWT | ALL | `payment.controller.createPayment` | Tạo hóa đơn |
| PUT | `/api/v1/payment/:id/status` | JWT | ADMIN, STAFF, CUSTOMER | `payment.controller.updatePaymentStatus` | Cập nhật trạng thái thanh toán |

---

### Nhóm ZaloPay (`/api/v1/zalopay`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/zalopay/callback` | Không (HMAC) | ZaloPay Server | `zalopay.controller.handleCallback` | Webhook callback từ ZaloPay |
| POST | `/api/v1/zalopay/create-order` | JWT | ALL | `zalopay.controller.createOrder` | Tạo đơn hàng ZaloPay |
| POST | `/api/v1/zalopay/query` | JWT | ALL | `zalopay.controller.queryOrder` | Kiểm tra trạng thái đơn hàng |

---

### Nhóm Fixed Schedule (`/api/v1/fixed-schedule`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/fixed-schedule` | JWT | ALL | `fixed-schedule.controller.createFixedSchedule` | Tạo lịch cố định |
| GET | `/api/v1/fixed-schedule` | JWT | ALL | `fixed-schedule.controller.queryFixedSchedules` | Danh sách lịch cố định |
| POST | `/api/v1/fixed-schedule/:id/matching/join` | JWT | ALL | `fixed-schedule.controller.joinFixedMatchingSchedule` | Tham gia lịch ghép trận cố định |
| POST | `/api/v1/fixed-schedule/:id/matching/leave` | JWT | ALL | `fixed-schedule.controller.leaveFixedMatchingSchedule` | Rời lịch ghép trận cố định |
| POST | `/api/v1/fixed-schedule/:id/occurrences/:date/cancel` | JWT | ALL | `fixed-schedule.controller.cancelFixedMatchingOccurrence` | Hủy một buổi |
| PUT | `/api/v1/fixed-schedule/:id/approve` | JWT | ALL | `fixed-schedule.controller.approveFixedSchedule` | Duyệt lịch |
| PUT | `/api/v1/fixed-schedule/:id/reject` | JWT | ALL | `fixed-schedule.controller.rejectFixedSchedule` | Từ chối lịch |
| PUT | `/api/v1/fixed-schedule/:id/pause` | JWT | ALL | `fixed-schedule.controller.pauseFixedSchedule` | Tạm dừng |
| PUT | `/api/v1/fixed-schedule/:id/resume` | JWT | ALL | `fixed-schedule.controller.resumeFixedSchedule` | Tiếp tục |
| PUT | `/api/v1/fixed-schedule/:id/cancel` | JWT | ALL | `fixed-schedule.controller.cancelFixedSchedule` | Hủy cả chuỗi |

---

### Nhóm Matching (`/api/v1/matching`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/matching/queue/join` | JWT | CUSTOMER | `matching.controller.joinQueue` | Vào hàng chờ ghép tự động |
| POST | `/api/v1/matching/queue/leave` | JWT | CUSTOMER | `matching.controller.leaveQueue` | Rời hàng chờ |
| GET | `/api/v1/matching/queue/status` | JWT | CUSTOMER | `matching.controller.getQueueStatus` | Xem trạng thái hàng chờ |
| POST | `/api/v1/matching` | JWT | CUSTOMER | `matching.controller.createSession` | Tạo phiên ghép trận |
| GET | `/api/v1/matching` | JWT | ALL | `matching.controller.querySessions` | Danh sách phiên ghép trận |
| GET | `/api/v1/matching/:id` | JWT | ALL | `matching.controller.getSessionDetail` | Chi tiết phiên |
| POST | `/api/v1/matching/:id/join` | JWT | CUSTOMER | `matching.controller.joinSession` | Tham gia phiên |
| POST | `/api/v1/matching/:id/leave` | JWT | CUSTOMER | `matching.controller.leaveSession` | Rời phiên |
| PUT | `/api/v1/matching/:id/members/:userId` | JWT | CUSTOMER | `matching.controller.updateMemberStatus` | Duyệt/từ chối thành viên |
| PUT | `/api/v1/matching/:id/status` | JWT | CUSTOMER | `matching.controller.updateSessionStatus` | Cập nhật trạng thái phiên |

---

### Nhóm Notification (`/api/v1/notification`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/notification` | JWT | ALL | `notification.controller.getMyNotifications` | Lấy thông báo của tôi |
| PUT | `/api/v1/notification/mark-all-read` | JWT | ALL | `notification.controller.markAllAsRead` | Đọc tất cả |
| PUT | `/api/v1/notification/:id/read` | JWT | ALL | `notification.controller.markAsRead` | Đọc một thông báo |
| POST | `/api/v1/notification` | JWT | ADMIN | `notification.controller.createSystemNotification` | Gửi thông báo hệ thống |

---

### Nhóm Reports (`/api/v1/reports`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| GET | `/api/v1/reports/court-performance` | JWT | STAFF, ADMIN | `reports.controller.getCourtPerformance` | Báo cáo hiệu suất sân |
| GET | `/api/v1/reports/advanced-performance` | JWT | STAFF, ADMIN | `reports.controller.getAdvancedPerformance` | Báo cáo nâng cao |

---

### Nhóm Review (`/api/v1/review`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| (theo route file review.routes.js) | - | JWT | - | `review.controller` | Tạo/xem đánh giá |

---

### Nhóm Upload (`/api/v1/upload`)

| Method | Endpoint | Auth | Role | Controller | Mô tả |
|--------|---------|------|------|-----------|-------|
| POST | `/api/v1/upload` | JWT | ALL | `upload.controller` | Upload ảnh lên Cloudinary |

---

### Health Check

| Method | Endpoint | Auth | Mô tả |
|--------|---------|------|-------|
| GET | `/health` | Không | Server health check (uptime, timestamp) |
| GET | `/api/v1/health` | Không | API health check |
| GET | `/api/v1/tracker` | Không | Dev: API tracker UI |
| GET | `/api/v1/export` | Không | Dev: Xuất danh sách API ra file .md |

---

## 6.2 API Quan trọng – Mô tả chi tiết

---

### API 1: Đăng nhập

```
POST /api/v1/auth/sign-in
```

**Mục đích:** Xác thực người dùng, nhận JWT token

**Header:** `Content-Type: application/json` *(không cần Authorization)*

**Request mẫu:**
```json
{
  "email": "customer@gmail.com",
  "password": "123456"
}
```

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Sign in successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "6847c1a2b3f4e5d6c7890123",
      "email": "customer@gmail.com",
      "role": "CUSTOMER",
      "status": "ACTIVE",
      "profile": {
        "name": "Nguyễn Văn A",
        "phone": "0901234567",
        "avatar_url": ""
      }
    }
  }
}
```

**Lỗi thường gặp:**
- `401 UNAUTHORIZED`: Sai mật khẩu hoặc email không tồn tại
- `403 FORBIDDEN`: Tài khoản bị khóa (BANNED/INACTIVE)

**File code:** `auth.controller.js`, `user-auth.service.js`

---

### API 2: Tạo Booking

```
POST /api/v1/booking
Authorization: Bearer {accessToken}
```

**Mục đích:** Tạo đặt sân mới, kiểm tra xung đột và tính giá

**Request mẫu:**
```json
{
  "court_id": "6847c1a2b3f4e5d6c7890456",
  "booking_date": "2026-06-20",
  "start_minutes": 480,
  "end_minutes": 600
}
```
*(start_minutes = 480 → 8:00 AM; end_minutes = 600 → 10:00 AM)*

**Response thành công (201):**
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "booking": {
      "_id": "6847c1a2b3f4e5d6c7890789",
      "user_id": "6847c1a2b3f4e5d6c7890123",
      "court_id": "6847c1a2b3f4e5d6c7890456",
      "booking_date": "2026-06-20",
      "start_minutes": 480,
      "end_minutes": 600,
      "total_price": 200000,
      "status": "PENDING",
      "created_at": "2026-06-16T03:00:00.000Z"
    },
    "payment": {
      "_id": "6847c1a2b3f4e5d6c7890abc",
      "booking_id": "6847c1a2b3f4e5d6c7890789",
      "user_id": "6847c1a2b3f4e5d6c7890123",
      "amount": 200000,
      "method": "CASH",
      "status": "PENDING"
    }
  }
}
```

**Lỗi thường gặp:**
- `409 CONFLICT`: Slot đã có booking trùng lịch
- `404 NOT_FOUND`: Court không tồn tại
- `400 BAD_REQUEST`: Court đang MAINTENANCE hoặc bị CourtBlock

---

### API 3: Duyệt booking (STAFF/ADMIN)

```
PUT /api/v1/booking/:id/status
Authorization: Bearer {staffToken}
```

**Request mẫu:**
```json
{
  "status": "CONFIRMED"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7890789",
    "status": "CONFIRMED",
    "updated_at": "2026-06-16T03:15:00.000Z"
  }
}
```

---

### API 4: Hủy booking

```
PUT /api/v1/booking/:id/cancel
Authorization: Bearer {accessToken}
```

**Request mẫu:**
```json
{
  "cancel_reason": "Bận đột xuất, không đến được"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7890789",
    "status": "CANCELLED",
    "cancel_reason": "Bận đột xuất, không đến được",
    "cancelled_by": "6847c1a2b3f4e5d6c7890123",
    "cancelled_at": "2026-06-16T04:00:00.000Z"
  }
}
```

---

### API 5: Tạo đơn hàng ZaloPay

```
POST /api/v1/zalopay/create-order
Authorization: Bearer {customerToken}
```

**Request mẫu:**
```json
{
  "paymentId": "6847c1a2b3f4e5d6c7890abc"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "order_url": "https://openapi.zalopay.vn/v2/order/checkout?token=...",
    "app_trans_id": "260616_1234567890",
    "zp_trans_token": "..."
  }
}
```

---

### API 6: Tạo phiên ghép trận

```
POST /api/v1/matching
Authorization: Bearer {customerToken}
```

**Request mẫu:**
```json
{
  "sport_id": "6847c1a2b3f4e5d6c7890111",
  "facility_id": "6847c1a2b3f4e5d6c7890222",
  "court_id": "6847c1a2b3f4e5d6c7890456",
  "booking_id": "6847c1a2b3f4e5d6c7890789",
  "booking_date": "2026-06-20",
  "start_minutes": 480,
  "end_minutes": 600,
  "total_players_needed": 6,
  "team_mode": "TEAM_VS_TEAM",
  "description": "Cần 3 người đội B, trình độ trung bình",
  "auto_approve": true,
  "payment_policy": "SPLIT_EQUALLY"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7891000",
    "host_id": "6847c1a2b3f4e5d6c7890123",
    "status": "OPEN",
    "team_mode": "TEAM_VS_TEAM",
    "members": [
      {
        "user_id": "6847c1a2b3f4e5d6c7890123",
        "status": "APPROVED",
        "team_code": "A",
        "join_mode": "INDIVIDUAL"
      }
    ]
  }
}
```

---

### API 7: Tham gia hàng đợi ghép tự động

```
POST /api/v1/matching/queue/join
Authorization: Bearer {customerToken}
```

**Request mẫu:**
```json
{
  "sport_id": "6847c1a2b3f4e5d6c7890111",
  "facility_id": "6847c1a2b3f4e5d6c7890222",
  "booking_date": "2026-06-20",
  "start_minutes": 480,
  "end_minutes": 600,
  "group_size": 4,
  "team_mode": "INDIVIDUAL",
  "payment_policy": "SPLIT_EQUALLY"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7892000",
    "status": "SEARCHING",
    "created_at": "2026-06-16T03:00:00.000Z"
  }
}
```

---

### API 8: Tạo lịch cố định

```
POST /api/v1/fixed-schedule
Authorization: Bearer {customerToken}
```

**Request mẫu:**
```json
{
  "type": "COURT_BOOKING",
  "sport_id": "6847c1a2b3f4e5d6c7890111",
  "facility_id": "6847c1a2b3f4e5d6c7890222",
  "court_id": "6847c1a2b3f4e5d6c7890456",
  "start_minutes": 480,
  "end_minutes": 600,
  "frequency": "WEEKLY",
  "days_of_week": [1, 3, 5],
  "start_date": "2026-06-20"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7893000",
    "status": "PENDING_APPROVAL",
    "frequency": "WEEKLY",
    "days_of_week": [1, 3, 5]
  }
}
```

---

### API 9: Duyệt lịch cố định

```
PUT /api/v1/fixed-schedule/:id/approve
Authorization: Bearer {staffOrAdminToken}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "6847c1a2b3f4e5d6c7893000",
    "status": "ACTIVE",
    "approved_by": "6847c1a2b3f4e5d6c7890999",
    "approved_at": "2026-06-16T05:00:00.000Z"
  }
}
```

---

### API 10: Báo cáo hiệu suất sân

```
GET /api/v1/reports/court-performance?facility_id=...&from=2026-06-01&to=2026-06-30
Authorization: Bearer {staffToken}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "facility_id": "6847c1a2b3f4e5d6c7890222",
    "period": { "from": "2026-06-01", "to": "2026-06-30" },
    "courts": [
      {
        "court_id": "6847c1a2b3f4e5d6c7890456",
        "court_name": "Sân A",
        "total_bookings": 45,
        "confirmed_bookings": 40,
        "total_revenue": 8000000,
        "occupancy_rate": 0.72
      }
    ],
    "summary": {
      "total_revenue": 8000000,
      "total_bookings": 45
    }
  }
}
```

---

### API 11: Health Check

```
GET /health
```

**Response (200):**
```json
{
  "status": "ok",
  "service": "sport-energy-backend",
  "uptime": 3600.5,
  "timestamp": "2026-06-16T03:00:00.000Z"
}
```
