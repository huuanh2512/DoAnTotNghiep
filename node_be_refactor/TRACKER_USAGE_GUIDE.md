# 🔔 Notification System Tracker Guide

Hướng dẫn chi tiết sử dụng các công cụ test notification system.

---

## 📱 Option 1: Web-based Tracker (Recommended)

### Cách Sử Dụng

1. **Khởi động server**
   ```bash
   npm run dev
   ```

2. **Mở tracker trong browser**
   ```
   http://localhost:3000/notification-tracker.html
   ```

3. **Nhập JWT Token**
   - Lấy JWT token từ API login
   - Dán vào field "JWT Token"
   - Click "🔗 Connect WebSocket"

4. **Test Endpoints**
   - **📥 Get Notifications**: Lấy danh sách thông báo
   - **✅ Mark as Read**: Đánh dấu một thông báo là đã đọc
   - **✔️ Mark All Read**: Đánh dấu tất cả là đã đọc

5. **Tạo Test Notification**
   - Điền User ID, Title, Content
   - Chọn Type (BOOKING, PAYMENT, SYSTEM, PROMOTION)
   - Click "🚀 Send Notification"

6. **Giám Sát Real-time**
   - Socket.IO status: Connected / Disconnected
   - Real-time notification list
   - Event log

### Features

✅ **Real-time Notifications** - Socket.IO connection  
✅ **API Testing** - Direct HTTP requests  
✅ **Event Log** - Socket events + API responses  
✅ **Persistent Storage** - Token saved in localStorage  
✅ **Responsive Design** - Mobile friendly  
✅ **Toast Notifications** - Success/Error messages  

---

## 💻 Option 2: CLI Tracker

### Installation

```bash
# CLI script already at: notification-tracker.js
node notification-tracker.js --token <JWT_TOKEN> --action <action>
```

### Actions

#### 1. List Notifications
```bash
node notification-tracker.js --token "eyJhbGciOiJIUzI1NiIs..." --action list

# Output:
# 📥 Fetching notifications...
# ✅ Loaded 5 notifications (2 unread)
# 
# 1. [BOOKING] Đặt sân thành công
#    Content: Lịch đặt sân của bạn vào ngày 2026-06-15...
#    Status: ❌ Unread
#    Date: 27/05/2026, 14:30:00
```

#### 2. Send Notification (Interactive)
```bash
node notification-tracker.js --token "eyJhbGciOiJIUzI1NiIs..." --action send

# Interactive prompts:
# 📤 Create Test Notification
# User ID: 607f1f77bcf86cd799439011
# Title: Test Notification
# Content: This is a test notification
# Type (SYSTEM/BOOKING/PAYMENT/PROMOTION) [SYSTEM]: BOOKING
```

#### 3. Mark All as Read
```bash
node notification-tracker.js --token "eyJhbGciOiJIUzI1NiIs..." --action mark-all

# Output:
# ✅ Marking all notifications as read...
# ✅ All notifications marked as read
```

#### 4. Register FCM Token (Interactive)
```bash
node notification-tracker.js --token "eyJhbGciOiJIUzI1NiIs..." --action register-fcm

# Interactive prompt:
# 📱 Register FCM Token
# FCM Token: eYdYc0JXOVJNRkM3Uk9oeFltSk...
```

---

## 🧪 Test Scenarios

### Scenario 1: Basic Notification Flow

1. **Lấy JWT Token**
   ```bash
   # Đăng nhập user thông qua API
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"user@example.com","password":"password"}'
   
   # Lưu token từ response: token = "eyJhbGciOiJIUzI1NiIs..."
   ```

2. **Kết nối WebSocket**
   - Mở tracker: http://localhost:3000/notification-tracker.html
   - Paste token → Click "🔗 Connect WebSocket"
   - Kiểm tra status: "● Connected"

3. **Tạo Test Notification (ADMIN role)**
   - Tab trái: Điền form "Create Test Notification"
   - User ID: Dán ID của user cần nhận
   - Title: "Test Booking"
   - Content: "This is a test notification"
   - Type: BOOKING
   - Click "🚀 Send Notification"

4. **Xác Nhận Nhận Được**
   - Tab phải: Real-time list cập nhật ngay
   - Unread count tăng
   - Event log hiển thị "📬 Notification Received"

### Scenario 2: Mark as Read Flow

1. Fetch notifications → Click "📥 Get Notifications"
2. Xem danh sách unread notifications
3. Click "✅ Mark as Read" → Status thay đổi
4. Unread count giảm

### Scenario 3: FCM Token Registration

```bash
node notification-tracker.js --token "YOUR_TOKEN" --action register-fcm

# Sau đó kiểm tra database:
# db.users.findOne({_id: userId})
# Sẽ có: { fcmTokens: ["token1", "token2", ...] }
```

---

## 🔐 Getting JWT Token for Testing

### Method 1: Via Auth API

```bash
# Register/Login user
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Response:
# {
#   "success": true,
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
# }
```

### Method 2: Create Test User in Database

```javascript
// Via MongoDB shell
db.users.insertOne({
  email: "tracker@test.com",
  password: "hashed_password",
  role: "CUSTOMER",
  status: "ACTIVE"
})

// Then login with this user
```

### Method 3: Use Existing User

- Sử dụng token từ lần đăng nhập trước
- Lưu token trong localStorage (tracker tự động save)

---

## 📊 Monitoring & Debugging

### Real-time Logs

Tracker hiển thị 2 loại logs:

**Socket Events**
- Connection/Disconnection
- Notifications received
- Errors

**API Responses**
- GET /notification
- POST /notification (create)
- PUT /notification/:id/read
- PUT /notification/mark-all-read

### Terminal Console

Mở DevTools (F12) → Console tab:
```javascript
// Check Socket.IO connection
console.log(socket.connected); // true/false

// Manual emit
socket.emit('ping');
socket.on('pong', () => console.log('Server is alive'));

// Check received notifications
console.log(notifications);
```

### Server Logs

Terminal chạy `npm run dev`:
```
[Socket.IO] User 607f... connected: abc123
[Socket.IO] Notification sent to user 607f...
[Socket.IO] User 607f... disconnected: abc123
```

---

## 🐛 Troubleshooting

### Problem: "❌ Disconnected from WebSocket"

**Solutions:**
1. Kiểm tra server chạy: `npm run dev`
2. Kiểm tra token hợp lệ
3. Kiểm tra CORS settings
4. Reload page và reconnect

### Problem: "⚠️ Please enter JWT token"

**Solutions:**
1. Get token từ API login trước
2. Paste token vào input field
3. Đảm bảo token không expire

### Problem: API returns 403 Forbidden

**Solutions:**
1. Nếu tạo notification: Cần ADMIN role
2. Kiểm tra token có đúng role không
3. Thử dengan admin account

### Problem: "EADDRINUSE: address already in use :::3000"

**Solutions:**
```bash
# Kill process đang dùng port 3000
netstat -ano | findstr :3000  # Find PID
taskkill /PID <PID> /F        # Kill process
npm run dev                     # Start again
```

---

## 📈 Performance Tips

1. **Limit Notifications Query**
   - Sử dụng pagination: `?skip=0&limit=20`
   - Không fetch tất cả cùng lúc

2. **Socket.IO Optimization**
   - Disconnect khi không dùng
   - Sử dụng rooms thay vì broadcast

3. **Database Indexes**
   - Notification model đã có compound index
   - Giúp query nhanh hơn

---

## 🚀 Advanced Usage

### Test Broadcast to Staff

```javascript
// Server side: src/services/notification.helper.js
await notificationHelper.notifyStaffAndAdmin({
  title: 'System Alert',
  content: 'Database maintenance at 2AM',
  type: 'SYSTEM'
});
```

### Test with Different Roles

```bash
# Get ADMIN token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin_password"
  }'

# Use admin token to create notifications for others
```

### Batch Testing

```bash
# Create 10 test notifications
for i in {1..10}; do
  node notification-tracker.js \
    --token "YOUR_TOKEN" \
    --action send
done
```

---

## 📞 Support

Nếu có vấn đề:
1. Check server logs: `npm run dev`
2. Check browser DevTools (F12)
3. Check notification-tracker Event Log
4. Xem IMPLEMENTATION_GUIDE.md để hiểu chi tiết API

---

**Created**: 2026-05-27  
**Status**: ✅ Ready for Testing
