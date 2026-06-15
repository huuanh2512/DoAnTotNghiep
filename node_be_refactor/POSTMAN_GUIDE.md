# 📮 Postman Collection - Hướng Dẫn Chi Tiết

Hướng dẫn từng bước sử dụng Postman Collection để test Notification System API.

---

## 📥 Step 1: Import Collection

### Option A: Drag & Drop
1. Mở Postman
2. Kéo file `Notification_System_API.postman_collection.json` vào Postman
3. Click "Import" khi có dialog

### Option B: Manual Import
1. Mở Postman
2. Click menu **File** → **Import**
3. Click **Upload Files**
4. Chọn file `Notification_System_API.postman_collection.json`
5. Click **Import**

### Option C: Link Import (nếu có public link)
1. Click **File** → **Import**
2. Paste URL hoặc raw JSON
3. Click **Import**

---

## ⚙️ Step 2: Setup Environment Variables

### Mục đích
Collection dùng variables để dễ thay đổi:
- `base_url` - Server API
- `jwt_token` - JWT token (auto-set)
- `current_user_id` - Current user ID
- `recipient_user_id` - User nhận notification
- `notification_id` - ID của notification

### Cách Setup

1. **Mở Environment Manager**
   - Click icon **Environment** (kế bên collection)
   - Hoặc: **Manage Environments** button

2. **Kiểm tra Variables**
   ```
   base_url = http://localhost:3000/api/v1
   jwt_token = (empty - sẽ auto-set)
   current_user_id = (empty - sẽ auto-set)
   recipient_user_id = (set manually)
   notification_id = (set when needed)
   ```

3. **Save Environment**
   - Click **Save** button

---

## 🔐 Step 3: Authentication - Register & Login

### Request 1: Register User
```
Folder: Authentication → Register User
Method: POST
URL: {{base_url}}/auth/register
```

**Body (raw JSON)**:
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### Request 2: Login User
```
Folder: Authentication → Login
Method: POST
URL: {{base_url}}/auth/login
```

**Body (raw JSON)**:
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Test Script** (Auto-save token):
```javascript
var jsonData = pm.response.json();
pm.environment.set('jwt_token', jsonData.token);
pm.environment.set('current_user_id', jsonData.user._id);
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "_id": "607f1f77bcf86cd799439011",
    "email": "test@example.com",
    "role": "CUSTOMER"
  }
}
```

**✅ Sau request này: jwt_token đã auto-saved!**

---

## 📥 Step 4: Retrieve Notifications

### Request 1: Get All Notifications
```
Folder: Notification - Retrieve → Get All Notifications
Method: GET
URL: {{base_url}}/notification?skip=0&limit=10
```

**Headers** (Auto from Bearer token):
```
Authorization: Bearer {{jwt_token}}
Content-Type: application/json
```

**Query Parameters**:
- `skip`: 0 (bỏ qua bao nhiêu records)
- `limit`: 10 (lấy bao nhiêu records)

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "unreadCount": 3,
  "items": [
    {
      "_id": "507f1f77bcf86cd799439070",
      "userId": "607f1f77bcf86cd799439011",
      "title": "Đặt sân thành công",
      "content": "Lịch đặt sân của bạn vào ngày 2026-06-15...",
      "type": "BOOKING",
      "metadata": {
        "bookingId": "123456",
        "link": "/bookings/123456"
      },
      "isRead": false,
      "createdAt": "2026-05-27T09:10:00.000Z"
    }
  ],
  "total": 25
}
```

**💡 Tip**: Lưu `_id` vào `notification_id` variable nếu cần test `Mark as Read`

---

### Request 2: Get Notifications (Page 2)
```
Folder: Notification - Retrieve → Get Notifications (Page 2)
Method: GET
URL: {{base_url}}/notification?skip=10&limit=10
```

**Khác điểm**: `skip=10` thay vì `skip=0`

---

## 📤 Step 5: Create Notifications

### Chuẩn Bị
Trước tạo notification cho user khác, cần:
1. Có 2 JWT tokens (hoặc 1 ADMIN token + 1 customer ID)
2. Set `recipient_user_id` variable

**Cách lấy recipient_user_id**:
1. Register user khác
2. Lưu `_id` từ response
3. Set vào environment: `recipient_user_id`

---

### Request 1: Create Booking Notification
```
Folder: Notification - Create → Create Booking Notification
Method: POST
URL: {{base_url}}/notification
```

**Headers**:
```
Authorization: Bearer {{jwt_token}}
Content-Type: application/json
```

**Body (raw JSON)**:
```json
{
  "userId": "{{recipient_user_id}}",
  "title": "Đặt sân thành công",
  "content": "Lịch đặt sân của bạn vào ngày 2026-06-15 đã được gửi và đang chờ duyệt.",
  "type": "BOOKING",
  "metadata": {
    "bookingId": "123456",
    "link": "/bookings/123456"
  }
}
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "Notification created successfully",
  "notification": {
    "_id": "507f1f77bcf86cd799439071",
    "userId": "{{recipient_user_id}}",
    "title": "Đặt sân thành công",
    "content": "...",
    "type": "BOOKING",
    "isRead": false,
    "createdAt": "2026-05-27T09:12:00.000Z"
  }
}
```

---

### Request 2: Create Payment Notification
```
Folder: Notification - Create → Create Payment Notification
Method: POST
URL: {{base_url}}/notification
```

**Body (raw JSON)**:
```json
{
  "userId": "{{recipient_user_id}}",
  "title": "Thanh toán thành công",
  "content": "Thanh toán 500,000 VNĐ cho lịch đặt sân đã được xác nhận.",
  "type": "PAYMENT",
  "metadata": {
    "paymentId": "789456",
    "bookingId": "123456",
    "link": "/payments/789456"
  }
}
```

---

### Request 3: Create System Notification
```
Folder: Notification - Create → Create System Notification
Method: POST
URL: {{base_url}}/notification
```

**Body (raw JSON)**:
```json
{
  "userId": "{{recipient_user_id}}",
  "title": "Cập nhật hệ thống",
  "content": "Hệ thống sẽ bảo trì vào 2AM-4AM hôm nay. Xin lỗi vì sự bất tiện.",
  "type": "SYSTEM"
}
```

---

### Request 4: Create Promotion Notification
```
Folder: Notification - Create → Create Promotion Notification
Method: POST
URL: {{base_url}}/notification
```

**Body (raw JSON)**:
```json
{
  "userId": "{{recipient_user_id}}",
  "title": "Khuyến mãi đặc biệt",
  "content": "Giảm 30% khi đặt sân vào cuối tuần. Mã code: WEEKEND30",
  "type": "PROMOTION"
}
```

---

## ✏️ Step 6: Update Notifications

### Request 1: Mark Single Notification as Read
```
Folder: Notification - Update → Mark Notification as Read
Method: PUT
URL: {{base_url}}/notification/{{notification_id}}/read
```

**Chuẩn bị**:
1. Run "Get All Notifications" request
2. Lấy `_id` từ response
3. Set vào environment: `notification_id`

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

### Request 2: Mark All Notifications as Read
```
Folder: Notification - Update → Mark All Notifications as Read
Method: PUT
URL: {{base_url}}/notification/mark-all-read
```

**Body**: (empty)

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

## 📱 Step 7: FCM Device Registration

### Request 1: Register FCM Token
```
Folder: FCM - Device Registration → Register FCM Token
Method: POST
URL: {{base_url}}/user/register-fcm
```

**Body (raw JSON)**:
```json
{
  "token": "eYdYc0JXOVJNRkM3Uk9oeFltSkZSV1JST0VNNU5UYzVOMmR5TVRObU0yUkJNakZHTkRKRk1UaFRWREJPTWpGSFIwRTJSRkkyTTI0d1JUVTURRJVDJZWUC0JFSEIzVEVKU2QwWlhSRTVCU0UxTlIwRlhWbU4zYTBGNllVRlROMDlVUVhKRmEwRkxUVk5TUTBKUVVtdEJSRkJrVkd0QlZGTlVUMJVRSEJhVm5CRmVrMXlTbXBWTWpCRlVtczBOMk5VUVhSWFJGTjBUMjEzYWsxRVNYbE5SMUo2VFhwQk1FMUVWbXRCVkZGa1UwTkJkMFZFUjJ0SVRWRjNSMEo1WW5gNlZ6MDk="
}
```

**💡 Note**: Dùng token giả để test. Untuk production, dapatkan token thực từ Firebase/Mobile

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "FCM token registered successfully",
  "fcmTokenCount": 1
}
```

---

### Request 2: Remove FCM Token
```
Folder: FCM - Device Registration → Remove FCM Token
Method: POST
URL: {{base_url}}/user/remove-fcm
```

**Body (raw JSON)**:
```json
{
  "token": "eYdYc0JXOVJNRkM3Uk9oeFltSkZSV1JST0VNNU5UYzVOMmR5TVRObU0yUkJNakZHTkRKRk1UaFRWREJPTWpGSFIwRTJSRkkyTTI0d1JUVTURRJVDJZWUC0JFSEIzVEVKU2QwWlhSRTVCU0UxTlIwRlhWbU4zYTBGNllVRlROMDlVUVhKRmEwRkxUVk5TUTBKUVVtdEJSRkJrVkd0QlZGTlVUMJVRSEJhVm5CRmVrMXlTbXBWTWpCRlVtczBOMk5VUVhSWFJGTjBUMjEzYWsxRVNYbE5SMUo2VFhwQk1FMUVWbXRCVkZGa1UwTkJkMFZFUjJ0SVRWRjNSMEo1WW5gNlZ6MDk="
}
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "FCM token removed successfully"
}
```

---

## 🧪 Complete Test Workflow

### Workflow 1: Test Create & Fetch Notifications

**Step 1**: Run "Login" request
```
✅ Token auto-saved to jwt_token
```

**Step 2**: Run "Get All Notifications"
```
✅ Check current notifications
✅ Save notification_id if needed
```

**Step 3**: Run "Create Booking Notification"
```
✅ Send notification to recipient
```

**Step 4**: Run "Get All Notifications" again
```
✅ Verify new notification appears
```

**Step 5**: Run "Mark Notification as Read"
```
✅ Verify status changes
```

---

### Workflow 2: Test All Notification Types

**Sequence**:
1. Login
2. Get Notifications (count initial)
3. Create Booking Notification
4. Create Payment Notification
5. Create System Notification
6. Create Promotion Notification
7. Get Notifications (verify all 4)
8. Mark All as Read
9. Get Notifications (verify isRead = true)

---

### Workflow 3: FCM Integration Test

**Sequence**:
1. Login
2. Register FCM Token (Check DB for fcmTokens array)
3. Register Another FCM Token (fcmTokenCount = 2)
4. Remove FCM Token (fcmTokenCount = 1)

---

## 💾 Save Request Responses

Postman tự động lưu response của setiap request. Để sử dụng:

1. Kiểm tra **Response** tab (bottom)
2. Copy data từ response
3. Paste vào Postman variables nếu cần

**Contoh**: Lấy notification ID từ response
```json
// Response dari Create Notification
{
  "notification": {
    "_id": "507f1f77bcf86cd799439071"  // ← Copy ID này
  }
}
```

Paste vào `notification_id` variable:
```
Set notification_id = "507f1f77bcf86cd799439071"
```

---

## 🔄 Using Variables in Requests

### 3 Cara Pakai Variables

1. **URL Parameters**
   ```
   {{base_url}}/notification/{{notification_id}}/read
   ```

2. **Body Parameters**
   ```json
   {
     "userId": "{{recipient_user_id}}"
   }
   ```

3. **Headers**
   ```
   Authorization: Bearer {{jwt_token}}
   ```

---

## 📊 Common Responses

### Success (200 OK)
```json
{
  "success": true,
  "message": "...",
  "data": {...}
}
```

### Error - Missing Token (401)
```json
{
  "success": false,
  "message": "Unauthorized: Missing or invalid token format",
  "code": "UNAUTHORIZED"
}
```

### Error - Forbidden (403)
```json
{
  "success": false,
  "message": "Forbidden: You do not have permission",
  "code": "FORBIDDEN"
}
```

### Error - Not Found (404)
```json
{
  "success": false,
  "message": "Notification not found or access denied",
  "code": "NOT_FOUND"
}
```

---

## 🧑‍💻 Pro Tips

### 1. Test Multiple Users
- Create 2-3 users qua Register API
- Lưu multiple JWT tokens
- Switch tokens via variables

### 2. Batch Testing
- Select multiple requests
- Right-click → **Run Collection**
- Postman Runner sẽ execute tất cả

### 3. Pre-request Scripts
Tạo script chạy trước request:
```javascript
// Example: Auto-generate timestamp
pm.environment.set('timestamp', new Date().toISOString());
```

### 4. Test Scripts
Tạo assertions sau request:
```javascript
pm.test("Status code is 200", function() {
  pm.response.to.have.status(200);
});

pm.test("Response has token", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.token).to.exist;
});
```

### 5. Export Results
- Click **Run Collection** → **Export Results**
- Share results với team

---

## 🐛 Troubleshooting

### Problem: "{{base_url}} undefined"
**Solution**: 
1. Check Environment is selected
2. Verify `base_url` variable exists
3. Click **Save** environment

### Problem: "Unauthorized" (401)
**Solution**:
1. Re-run Login request
2. Check `jwt_token` variable has value
3. Verify token not expired

### Problem: "ECONNREFUSED"
**Solution**:
1. Check server running: `npm run dev`
2. Check port: 3000
3. Check `base_url`: http://localhost:3000/api/v1

### Problem: "Socket hang up"
**Solution**:
1. Server crashed
2. Restart: `npm run dev`
3. Kill and restart port

---

## 📋 Checklist Before Testing

- [ ] Server running: `npm run dev`
- [ ] Database connected
- [ ] Postman installed
- [ ] Collection imported
- [ ] Environment setup
- [ ] base_url = http://localhost:3000/api/v1
- [ ] Have test user email & password

---

## 🎯 Quick Reference

| Action | Steps |
|--------|-------|
| **Login** | Click Login request → Send |
| **Get Notifications** | Click Get All Notifications → Send |
| **Create Notification** | Fill variables → Choose notification type → Send |
| **Mark as Read** | Set notification_id → Click Mark as Read → Send |
| **Register FCM** | Fill token → Click Register FCM Token → Send |

---

## 📞 Need Help?

1. Check response status code
2. Read error message
3. Check variables are set
4. Check server logs
5. See TRACKER_USAGE_GUIDE.md for more examples

---

**Created**: 2026-05-27  
**Status**: ✅ Ready for Testing
