# Backend API Documentation

**Base URL:** `http://<host>:<port>/api/v1`

> Tất cả API ngoại trừ `auth` yêu cầu header `Authorization: Bearer <token>`.

---

## Tổng quan phản hồi chung

- `200 OK`:
  - Thành công: `success: true`
  - Có thể có trường `message`, `code`, và dữ liệu cụ thể.
- `400 Bad Request`:
  - Lỗi đầu vào / thiếu trường / cập nhật sai.
  - `success: false`, `message`, `code`.
- `401 Unauthorized`:
  - Thiếu hoặc token không hợp lệ.
  - Do middleware xác thực.
- `403 Forbidden`:
  - Người dùng không đủ quyền.
- `404 Not Found`:
  - Không tìm thấy tài nguyên (ví dụ: `facility`, `booking`, `notification`).
- `500 Internal Server Error`:
  - Lỗi server chung.

---

## 1. Health & Utility

### GET /health

- Mô tả: Kiểm tra API.
- Yêu cầu: không.
- Response thành công:
```json
{
  "success": true,
  "message": "API is running",
  "code": "OK"
}
```

### GET /export

- Mô tả: Xuất danh sách các endpoint hiện có thành file Markdown.
- Yêu cầu: không.
- Response thành công: tải file Markdown.

### GET /tracker

- Mô tả: UI tracker hiển thị trạng thái API.
- Yêu cầu: không.

---

## 2. Auth

### POST /auth/register

- Request body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Registration successful",
  "code": "OK",
  "data": {
    "userId": "...",
    "email": "user@example.com"
  }
}
```
- Error `400` khi thiếu email/password.
- Error `500` khi lỗi server.

### POST /auth/sign-in

- Request body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Authentication successful",
  "code": "OK",
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "user": { ... }
  }
}
```
- Error `400` khi thiếu email/password.
- Error `401` khi xác thực thất bại.

### POST /auth/refresh-token

- Request body:
```json
{
  "refreshToken": "..."
}
```
- Response success `200` giống sign-in, trả token mới.
- Error `400` khi thiếu refreshToken.
- Error `401` khi refresh token không hợp lệ.

### POST /auth/sign-out

- Request body:
```json
{
  "userId": "..."
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Sign out successful",
  "code": "SIGNOUT_SUCCESS"
}
```

### POST /auth/reset-password

- Request body:
```json
{
  "email": "user@example.com",
  "newPassword": "newPassword123"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Password reset successfully",
  "code": "PASSWORD_RESET"
}
```

---

## 3. User

> Tất cả endpoint `user` yêu cầu `Authorization: Bearer <token>`.

### GET /user/:id

- Mô tả: Lấy chi tiết người dùng.
- Response success `200`:
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "user": {
    "id": "...",
    "email": "...",
    "name": "...",
    "role": "...",
    "facility": { "id": "...", "name": "..." },
    ...
  }
}
```
- Error `404` nếu không tìm thấy.
- Error `403` nếu user không được phép sửa thông tin khác (chỉ cho update).

### PUT /user/:id

- Request body:
```json
{
  "profile": { ... },
  "facilityName": "Optional facility name"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": { ... }
}
```
- Error `400`, `403`, `404`.

### POST /user/register-fcm

- Request body:
```json
{
  "token": "fcm_device_token"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "FCM token registered successfully",
  "fcmTokenCount": 1
}
```

### POST /user/remove-fcm

- Request body:
```json
{
  "token": "fcm_device_token"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "FCM token removed successfully"
}
```

### GET /user

- Quyền: `ADMIN`.
- Query params:
  - `skip`, `limit`, và filter tùy.
- Response success `200`:
```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "items": [ ... ],
  "total": 123
}
```

### PUT /user/:id/role

- Quyền: `ADMIN`.
- Request body:
```json
{
  "role": "ADMIN" // hoặc STAFF, CUSTOMER
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "User role updated successfully",
  "code": "ROLE_UPDATED"
}
```

### PUT /user/:id/status

- Quyền: `ADMIN`.
- Request body:
```json
{
  "status": "ACTIVE" // hoặc giá trị khác tùy app
}
```
```
- Response success `200`:
```json
{
  "success": true,
  "message": "User status updated successfully",
  "code": "STATUS_UPDATED"
}
```

### POST /user/:id/assign-facility

- Quyền: `ADMIN`.
- Request body:
```json
{
  "facilityId": "..."
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Facility assigned successfully",
  "code": "FACILITY_ASSIGNED"
}
```

---

## 4. Facility

> Các endpoint `facility` yêu cầu `Authorization: Bearer <token>`.

### GET /facility

- Query params:
  - `skip`, `limit`
  - `active` (`true` / `false`)
  - `city`
- Response success `200`:
```json
{
  "success": true,
  "message": "Facilities retrieved successfully",
  "items": [
    {
      "id": "...",
      "name": "...",
      "address": {
        "city": "...",
        "full": "..."
      },
      "active": true,
      "staffIds": [ ... ],
      "createdAt": "..."
    }
  ],
  "total": 10
}
```

### GET /facility/:id

- Mô tả: Lấy chi tiết cơ sở cụ thể.
- Response success `200`:
```json
{
  "success": true,
  "message": "Facility retrieved successfully",
  "facility": {
    "_id": "6a0f022b22c105b435bb0e4d",
    "name": "Tên Cơ Sở",
    "city": "Hà Nội",
    "fullAddress": "Địa chỉ chi tiết...",
    "active": true
  }
}
```
- Error `404` nếu không tồn tại.

### POST /facility

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Tên cơ sở",
  "city": "Hà Nội",
  "fullAddress": "Địa chỉ chi tiết...",
  "active": true,
  "staffIds": ["...", "..."]
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Facility created successfully",
  "facility": { ... }
}
```

### PUT /facility/:id

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Tên mới",
  "city": "Hà Nội",
  "fullAddress": "Địa chỉ mới",
  "active": false,
  "staffIds": ["...", "..."]
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Facility updated successfully",
  "facility": { ... }
}
```

### DELETE /facility/:id

- Quyền: `ADMIN`.
- Response success `200`:
```json
{
  "success": true,
  "message": "Facility deleted successfully",
  "code": "DELETE_SUCCESS"
}
```

---

## 5. Court

> `court` yêu cầu `Authorization: Bearer <token>`.

### GET /court

- Query params:
  - `skip`, `limit`
  - `facilityId`
  - `sportId`
  - `status`
- Response success `200`:
```json
{
  "success": true,
  "message": "Courts retrieved successfully",
  "items": [ ... ],
  "total": 10
}
```

### POST /court

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Court A",
  "facilityId": "...",
  "sportId": "...",
  "code": "C1",
  "status": "ACTIVE",
  "pricePerHour": 200000
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Court created successfully",
  "court": { ... }
}
```

### PUT /court/:id

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Court A",
  "facilityId": "...",
  "sportId": "...",
  "code": "C1",
  "status": "ACTIVE",
  "pricePerHour": 220000
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Court updated successfully",
  "court": { ... }
}
```

### DELETE /court/:id

- Quyền: `ADMIN`.
- Response success `200`:
```json
{
  "success": true,
  "message": "Court deleted successfully",
  "code": "DELETE_SUCCESS"
}
```

### GET /court/:id/slot-config

- Mô tả: Lấy cấu hình slot của court.
- Response success `200`:
```json
{
  "success": true,
  "message": "Slot config retrieved successfully",
  "config": {
    "openingMinutes": 480,
    "closingMinutes": 1320,
    "slotDurationMinutes": 60,
    "slots": [ ... ]
  }
}
```

### PUT /court/:id/slot-config

- Quyền: `ADMIN`, `STAFF`.
- Request body:
```json
{
  "openingMinutes": 480,
  "closingMinutes": 1320,
  "slotDurationMinutes": 60,
  "slots": [ ... ]
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Slot config updated successfully",
  "config": { ... }
}
```

---

## 6. Sport

> `sport` yêu cầu `Authorization: Bearer <token>`.

### GET /sport

- Query params: `skip`, `limit`, filter tùy.
- Response success `200`:
```json
{
  "success": true,
  "message": "Sports retrieved successfully",
  "items": [ ... ],
  "total": 5
}
```

### POST /sport

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Football",
  "description": "...",
  "teamSize": 11,
  "active": true
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Sport created successfully",
  "sport": { ... }
}
```

### PUT /sport/:id

- Quyền: `ADMIN`.
- Request body:
```json
{
  "name": "Football",
  "description": "...",
  "teamSize": 11,
  "active": true
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Sport updated successfully",
  "sport": { ... }
}
```

### DELETE /sport/:id

- Quyền: `ADMIN`.
- Response success `200`:
```json
{
  "success": true,
  "message": "Sport deleted successfully",
  "code": "DELETE_SUCCESS"
}
```

---

## 7. Booking

> `booking` yêu cầu `Authorization: Bearer <token>`.

### GET /booking

- Query params:
  - `skip`, `limit`
  - `courtId`, `status`, `bookingDate`, `facilityId`, ...
  - Nếu login là `CUSTOMER`, chỉ trả booking của chính user.
- Response success `200`:
```json
{
  "success": true,
  "message": "Bookings retrieved successfully",
  "items": [ ... ],
  "total": 20
}
```

### POST /booking

- Request body:
```json
{
  "courtId": "...",
  "bookingDate": "2026-05-28",
  "startMinutes": 540,
  "endMinutes": 600,
  "totalPrice": 200000
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Booking created successfully",
  "booking": { ... }
}
```
- Error `400` khi thiếu `courtId`, `bookingDate`, `startMinutes`, `endMinutes`.

### GET /booking/:id

- Response success `200`:
```json
{
  "success": true,
  "message": "Booking detail retrieved successfully",
  "booking": {
    "id": "...",
    "court": { ... },
    "user": { ... },
    "bookingDate": "...",
    "startMinutes": 540,
    "endMinutes": 600,
    "totalPrice": 200000,
    ...
  }
}
```
- Error `403` nếu `CUSTOMER` cố xem booking của người khác.
- Error `404` nếu không tìm thấy.

### PUT /booking/:id/status

- Quyền: `ADMIN`, `STAFF`.
- Request body:
```json
{
  "status": "CONFIRMED"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Booking status updated successfully",
  "booking": { ... }
}
```

---

## 8. Payment

> `payment` yêu cầu `Authorization: Bearer <token>`.

### GET /payment

- Query params: `skip`, `limit`, `bookingId`, `status`, ...
- Nếu role `CUSTOMER`, chỉ trả payment của chính user.
- Response success `200`:
```json
{
  "success": true,
  "message": "Payments retrieved successfully",
  "items": [ ... ],
  "total": 10
}
```

### POST /payment

- Request body:
```json
{
  "bookingId": "...",
  "amount": 200000,
  "method": "CARD",
  "transactionId": "..."
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Payment created successfully",
  "payment": { ... }
}
```

### PUT /payment/:id/status

- Quyền: `ADMIN`, `STAFF`.
- Request body:
```json
{
  "status": "PAID",
  "transactionId": "..."
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Payment status updated successfully",
  "payment": { ... }
}
```

---

## 9. Review

> `review` yêu cầu `Authorization: Bearer <token>`.

### GET /review

- Query params: `skip`, `limit`, `courtId`, ...
- Response success `200`:
```json
{
  "success": true,
  "message": "Reviews retrieved successfully",
  "items": [ ... ],
  "total": 10
}
```

### POST /review

- Request body:
```json
{
  "courtId": "...",
  "rating": 4,
  "comment": "Good court"
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Review created successfully",
  "review": { ... }
}
```
- Error `400` khi thiếu `courtId` hoặc `rating`.
- Error `400` khi rating không trong 1..5.

### DELETE /review/:id

- Quyền: `ADMIN`.
- Response success `200`:
```json
{
  "success": true,
  "message": "Review deleted successfully",
  "code": "DELETE_SUCCESS"
}
```

---

## 10. Notification

> `notification` yêu cầu `Authorization: Bearer <token>`.

### GET /notification

- Query params: `skip`, `limit`.
- Response success `200`:
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "unreadCount": 3,
  "items": [ ... ],
  "total": 12
}
```

### PUT /notification/mark-all-read

- Response success `200`:
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "code": "MARK_ALL_SUCCESS"
}
```

### PUT /notification/:id/read

- Response success `200`:
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```
- Error `404` nếu không tìm thấy thông báo.

### POST /notification

- Quyền: `ADMIN`.
- Request body:
```json
{
  "userId": "...",
  "title": "Thông báo mới",
  "content": "Nội dung...",
  "body": "Nội dung...",
  "type": "INFO",
  "metadata": { "key": "value" }
}
```
- Response success `200`:
```json
{
  "success": true,
  "message": "Notification created successfully",
  "notification": { ... }
}
```

---

## 11. Upload

> `upload` yêu cầu `Authorization: Bearer <token>`.

### POST /upload/single

- Form-data field: `file`
- Response success `200`:
```json
{
  "success": true,
  "message": "Tải ảnh lên thành công",
  "data": {
    "filename": "...",
    "path": "...",
    ...
  }
}
```
- Error `400` khi không có file.

### POST /upload/multiple

- Form-data fields: `files`
- Response success `200`:
```json
{
  "success": true,
  "message": "Tải các ảnh lên thành công",
  "data": [ ... ]
}
```
- Error `400` khi không có file.

---

## 12. Error responses chung

### 400 Bad Request
```json
{
  "success": false,
  "message": "Missing required booking fields",
  "code": "MISSING_FIELDS"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "code": "UNAUTHORIZED"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Forbidden: You can only view your own bookings",
  "code": "FORBIDDEN"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Facility not found",
  "code": "NOT_FOUND"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal Server Error",
  "code": "SERVER_ERROR"
}
```
