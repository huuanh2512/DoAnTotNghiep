<!-- IMPLEMENTATION_GUIDE.md -->
# 📋 Hướng Dẫn Triển Khai Hệ Thống Thông Báo (Notification System)

## ✅ Trạng Thái Triển Khai

Dự án đã hoàn thành triển khai các thành phần sau theo specification:

### 1. **Database Schema** ✅
- ✔ Model `Notification` với fields: `userId`, `title`, `content`, `type`, `metadata`, `isRead`
- ✔ Compound index: `{ userId: 1, isRead: 1, createdAt: -1 }`
- ✔ Model `User` với field `fcmTokens` để lưu token push notification

### 2. **REST API Endpoints** ✅
- ✔ `GET /api/v1/notification/` - Lấy danh sách thông báo của user
- ✔ `POST /api/v1/notification/` - Tạo thông báo (ADMIN only)
- ✔ `PUT /api/v1/notification/:id/read` - Đánh dấu 1 thông báo là đã đọc
- ✔ `PUT /api/v1/notification/mark-all-read` - Đánh dấu tất cả thông báo là đã đọc
- ✔ `POST /api/v1/user/register-fcm` - Đăng ký FCM token
- ✔ `POST /api/v1/user/remove-fcm` - Gỡ bỏ FCM token

### 3. **Real-time Notifications (Socket.IO)** ✅
- ✔ Tích hợp Socket.IO vào server
- ✔ Authentication qua JWT token
- ✔ Room management: `user_${userId}`, `room_staff`, `room_admin`
- ✔ Event emit: `notification_received`

### 4. **FCM Integration** ✅
- ✔ Service để đăng ký/gỡ bỏ FCM tokens
- ✔ Template function cho sending push notifications
- ✔ Cleanup invalid tokens

### 5. **Notification Helper** ✅
- ✔ Tiện ích phát sóng thông báo từ các business logic khác
- ✔ Pre-built templates cho Booking, Payment events

---

## 🚀 Cách Sử Dụng

### A. API Endpoints

#### 1. Lấy danh sách thông báo
```bash
curl -X GET http://localhost:3000/api/v1/notification?skip=0&limit=10 \
  -H "Authorization: Bearer <jwt_token>"

# Response:
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "unreadCount": 3,
  "items": [
    {
      "_id": "507f1f77bcf86cd799439070",
      "userId": "507f1f77bcf86cd799439011",
      "title": "Đặt sân thành công",
      "content": "Lịch đặt sân của bạn vào ngày 2026-06-15 đã được gửi và đang chờ duyệt.",
      "type": "BOOKING",
      "metadata": { "bookingId": "...", "link": "/bookings/..." },
      "isRead": false,
      "createdAt": "2026-05-27T09:10:00Z"
    }
  ],
  "total": 25
}
```

#### 2. Tạo thông báo (chỉ ADMIN)
```bash
curl -X POST http://localhost:3000/api/v1/notification \
  -H "Authorization: Bearer <admin_jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "507f1f77bcf86cd799439011",
    "title": "Lịch đặt sân được duyệt",
    "content": "Lịch đặt sân của bạn vào ngày 2026-06-15 đã được duyệt.",
    "type": "BOOKING",
    "metadata": {
      "bookingId": "507f1f77bcf86cd799439099",
      "link": "/bookings/507f1f77bcf86cd799439099"
    }
  }'
```

#### 3. Đánh dấu một thông báo là đã đọc
```bash
curl -X PUT http://localhost:3000/api/v1/notification/507f1f77bcf86cd799439070/read \
  -H "Authorization: Bearer <jwt_token>"
```

#### 4. Đánh dấu tất cả thông báo là đã đọc
```bash
curl -X PUT http://localhost:3000/api/v1/notification/mark-all-read \
  -H "Authorization: Bearer <jwt_token>"
```

#### 5. Đăng ký FCM token (Mobile)
```bash
curl -X POST http://localhost:3000/api/v1/user/register-fcm \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eWdYc0JXOVJNRkM3Uk9oeFltSk..."
  }'
```

### B. Real-time Socket.IO (Frontend)

#### JavaScript/React Client
```javascript
import io from 'socket.io-client';

// Kết nối WebSocket với JWT token
const socket = io('http://localhost:3000', {
  auth: {
    token: localStorage.getItem('jwt_token')
  }
});

// Lắng nghe thông báo real-time
socket.on('notification_received', (data) => {
  console.log('Thông báo mới:', data);
  // data.event = 'new_notification'
  // data.data = { title, content, type, metadata, ... }
  // data.timestamp = "2026-05-27T09:10:00Z"
  
  // Cập nhật UI, phát âm thanh, hiển thị toast, v.v.
  showNotificationToast(data.data);
  playNotificationSound();
  updateBadgeCount();
});

// Kiểm tra kết nối
socket.emit('ping');
socket.on('pong', () => {
  console.log('Socket connected!');
});
```

### C. Từ Business Logic (Backend)

#### Phát thông báo cho User cụ thể
```javascript
// src/services/booking.service.js
const notificationHelper = require('./notification.helper');

async function createBooking(bookingData) {
  // ... logic tạo booking ...
  const newBooking = await BookingRepository.create(bookingData);

  // Phát thông báo cho customer
  await notificationHelper.notifyBookingCreated(newBooking);

  return newBooking;
}
```

#### Phát thông báo cho Staff/Admin
```javascript
await notificationHelper.notifyStaffAndAdmin({
  title: 'Yêu cầu rút tiền mới',
  content: 'Chủ sân ${facilityName} vừa yêu cầu rút tiền 5 triệu VNĐ',
  type: 'SYSTEM',
  metadata: {
    withdrawalId: withdrawal._id,
    link: '/withdrawals/...'
  }
});
```

---

## 📦 Dependencies

Package `socket.io` đã được thêm vào `package.json`. Chạy:
```bash
npm install
```

Nếu cần Firebase Admin SDK cho FCM push notifications:
```bash
npm install firebase-admin
```

---

## ⚙️ Cấu Hình

### Environment Variables (.env)
```
PORT=3000
MONGODB_URI=mongodb://...
JWT_SECRET=your_secret_key
# FCM/Firebase config (tùy chọn)
FIREBASE_PROJECT_ID=...
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...
```

---

## 🔧 Tích Hợp từng module

### 1. Booking Service
```javascript
// Thêm vào src/services/booking.service.js
const notificationHelper = require('./notification.helper');

// Khi tạo booking mới
await notificationHelper.notifyBookingCreated(newBooking);

// Khi duyệt booking
await notificationHelper.notifyBookingApproved(booking);

// Khi hủy booking
await notificationHelper.notifyBookingCancelled(booking, 'Khách yêu cầu hủy');
```

### 2. Payment Service
```javascript
// Thêm vào src/services/payment.service.js
const notificationHelper = require('./notification.helper');

// Khi thanh toán thành công
await notificationHelper.notifyPaymentSuccess(payment);

// Khi thanh toán thất bại
await notificationHelper.notifyPaymentFailed(payment, 'Thẻ bị từ chối');
```

### 3. User Service
```javascript
// Thêm vào src/services/user.service.js
const fcmService = require('./fcm.service');

// Khi logout, gỡ bỏ FCM token
await fcmService.removeFCMToken(userId, fcmToken);
```

---

## 🎯 Hướng Dẫn Frontend

### Web Dashboard (React/Vue/Angular)

1. **Kết nối Socket.IO**
```javascript
// App.js hoặc main.js
useEffect(() => {
  const socket = io(API_URL, {
    auth: { token: localStorage.getItem('token') }
  });
  
  socket.on('notification_received', (data) => {
    // Cập nhật state
    setUnreadCount(prev => prev + 1);
    
    // Hiển thị toast
    Toast.show({
      title: data.data.title,
      description: data.data.content,
      status: 'info'
    });
    
    // Phát âm thanh
    new Audio('/notification.mp3').play();
  });
  
  return () => socket.disconnect();
}, []);
```

2. **Hiển thị Badge số lượng**
```javascript
<Badge count={unreadCount} showZero>
  <NotificationIcon />
</Badge>
```

3. **Danh sách thông báo**
```javascript
async function fetchNotifications() {
  const response = await fetch(
    `/api/v1/notification?skip=0&limit=10`,
    { headers: { 'Authorization': `Bearer ${token}` } }
  );
  const data = await response.json();
  setUnreadCount(data.unreadCount);
  setNotifications(data.items);
}
```

### Mobile App (React Native / Flutter)

1. **Đăng ký FCM Token**
```javascript
// App.js
import messaging from '@react-native-firebase/messaging';

useEffect(() => {
  const getFCMToken = async () => {
    try {
      const token = await messaging().getToken();
      await fetch('/api/v1/user/register-fcm', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${jwtToken}`
        },
        body: JSON.stringify({ token })
      });
    } catch (error) {
      console.error('FCM registration failed:', error);
    }
  };
  
  getFCMToken();
}, []);
```

2. **Lắng nghe Push Notifications**
```javascript
messaging().onMessage(async (remoteMessage) => {
  // Hiển thị thông báo khi app mở
  Alert.alert(
    remoteMessage.notification.title,
    remoteMessage.notification.body
  );
});

messaging().setBackgroundMessageHandler(async (remoteMessage) => {
  // Xử lý khi app đang chạy background
  console.log('Background message:', remoteMessage);
});
```

---

## 📝 API Response Format

### Success Response
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "...",
  "code": "ERROR_CODE"
}
```

---

## 🧪 Testing

### Test lấy danh sách thông báo
```bash
# Tạo user và đăng nhập trước để lấy token
curl -X GET http://localhost:3000/api/v1/notification \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

### Test Socket.IO Connection
Sử dụng client test như [Socket.IO Test Client](https://socket.io/docs/v4/socket-io-client-api/) hoặc Postman

---

## 🐛 Troubleshooting

### Socket.IO không kết nối được
- Kiểm tra CORS cấu hình
- Đảm bảo JWT token hợp lệ
- Kiểm tra port mở và server chạy

### FCM Push Notifications không gửi được
- Cần cài đặt Firebase Admin SDK
- Cấu hình Firebase credentials
- Kiểm tra FCM token hợp lệ từ client

### Database Schema mismatch
- Xóa database cũ hoặc migrate
- Thực hiện `npm install` lại

---

## 📚 Tham khảo

- [Socket.IO Documentation](https://socket.io/docs/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [MongoDB Indexes](https://docs.mongodb.com/manual/indexes/)

---

## 🎓 Kế tiếp - Optional Enhancements

1. **Web Push Notifications** - Service Worker cho web dashboard
2. **Notification Templates** - Thêm template engine cho nội dung động
3. **Analytics** - Theo dõi tỷ lệ đọc thông báo
4. **Email Integration** - Gửi email theo thông báo quan trọng
5. **Scheduling** - Gửi thông báo tự động theo thời gian
6. **Bulk Notification** - API gửi thông báo cho nhóm users

---

**Generated**: 2026-05-27
**Status**: ✅ Implementation Complete
