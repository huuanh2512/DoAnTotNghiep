# 🧪 Testing Tools for Notification System

Ba công cụ đã được tạo để test notification system một cách thuận tiện.

---

## 🎯 Công Cụ Test Có Sẵn

### 1. 🌐 Web-based Tracker (Recommended)
**File**: `public/notification-tracker.html`

**Cách sử dụng**:
```bash
# Terminal 1: Start server
npm run dev

# Terminal 2: Open in browser
http://localhost:3000/notification-tracker.html
```

**Features**:
- ✅ Real-time Socket.IO connection
- ✅ Web UI cho dễ sử dụng
- ✅ Event log (Socket + API)
- ✅ Persistent token (localStorage)
- ✅ Responsive design

---

### 2. 💻 CLI Tracker
**File**: `notification-tracker.js`

**Cách sử dụng**:
```bash
# List notifications
node notification-tracker.js --token "YOUR_JWT_TOKEN" --action list

# Send notification (interactive)
node notification-tracker.js --token "YOUR_JWT_TOKEN" --action send

# Mark all as read
node notification-tracker.js --token "YOUR_JWT_TOKEN" --action mark-all

# Register FCM token (interactive)
node notification-tracker.js --token "YOUR_JWT_TOKEN" --action register-fcm
```

**Pros**:
- ✅ Nhanh, không cần browser
- ✅ Script tự động hóa
- ✅ Terminal friendly

---

### 3. 📮 Postman Collection
**File**: `Notification_System_API.postman_collection.json`

**Cách sử dụng**:
1. Mở Postman
2. Click "Import" → Chọn file `.json`
3. Environment variables auto-setup
4. Test các endpoint

**Requests có sẵn**:
- Register/Login
- Get Notifications (with pagination)
- Create Notifications (BOOKING, PAYMENT, SYSTEM, PROMOTION)
- Mark as Read
- Mark All as Read
- Register/Remove FCM Token

---

## 🚀 Quick Start

### Step 1: Lấy JWT Token

**Option A: Via Web Tracker**
- Mở: http://localhost:3000/notification-tracker.html
- Xem hướng dẫn lấy token

**Option B: Via Auth API**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password"
  }'

# Save token từ response
```

### Step 2: Chọn Testing Tool

**Web Tracker** → Nhập token → Click Connect  
**CLI** → `node notification-tracker.js --token "TOKEN" --action list`  
**Postman** → Import collection → Set jwt_token variable

### Step 3: Start Testing

- Fetch notifications
- Create test notifications
- Mark as read
- Register FCM tokens

---

## 📊 Feature Comparison

| Feature | Web Tracker | CLI | Postman |
|---------|------------|-----|---------|
| Real-time Socket.IO | ✅ | ❌ | ❌ |
| List Notifications | ✅ | ✅ | ✅ |
| Create Notifications | ✅ | ✅ | ✅ |
| Mark as Read | ✅ | ✅ | ✅ |
| Register FCM | ✅ | ✅ | ✅ |
| Event Logging | ✅ | ✅ | ✅ |
| UI Interface | ✅ | ❌ | ✅ |
| CLI Automation | ❌ | ✅ | ❌ |
| Environment Vars | localStorage | CLI args | Postman env |
| Batch Testing | ❌ | ✅ | ✅ (with runner) |

---

## 💡 Use Cases

### Use Web Tracker When:
- Đang develop frontend integration
- Cần observe real-time notifications
- Debug Socket.IO connection
- UI/UX friendly interface

### Use CLI When:
- Test lẹ, không cần UI
- Automation scripts
- CI/CD pipelines
- Batch testing

### Use Postman When:
- Team collaboration
- API documentation
- Request history
- Test workflows (runner)

---

## 🔧 Configuration

### Environment Variables (Postman)

```
base_url = http://localhost:3000/api/v1
jwt_token = (auto-set by Login request)
current_user_id = (auto-set by Login request)
recipient_user_id = (set manually)
notification_id = (set when needed)
```

### Local Storage (Web Tracker)

- Token được tự động save
- Refresh page → token vẫn có
- Clear cache để reset

---

## 📝 Example Workflows

### Workflow 1: Complete Flow Test

```
1. Web Tracker: Connect WebSocket
2. CLI: node notification-tracker.js --token "TOKEN" --action list
3. Postman: Create test notification
4. Web Tracker: Observe real-time update
5. Postman: Mark as read
6. CLI: Verify status changed
```

### Workflow 2: Batch Test

```bash
# Script to send 10 notifications
for i in {1..10}; do
  echo "Sending notification $i..."
  node notification-tracker.js --token "TOKEN" --action send
done

# Then check all in Web Tracker
```

### Workflow 3: FCM Integration Test

```
1. CLI: Register FCM token
2. Postman: Check user.fcmTokens in MongoDB
3. (Optional) Firebase: Test push notification
4. Mobile app: Receive push notification
```

---

## 🎓 Documentation References

- **Web Tracker**: See TRACKER_USAGE_GUIDE.md
- **API Endpoints**: See IMPLEMENTATION_GUIDE.md
- **Deployment**: See DEPLOYMENT_SUMMARY.md

---

## 🐛 Troubleshooting

### Web Tracker Issues
- Check server running: `npm run dev`
- Check browser DevTools (F12)
- Reload page

### CLI Issues
- Verify token format: `node notification-tracker.js --token "TOKEN" --action list`
- Check server port: 3000

### Postman Issues
- Import collection properly
- Set base_url variable
- Check Bearer token header

---

## 📞 Quick Commands

```bash
# Start development server
npm run dev

# Test via CLI (list)
node notification-tracker.js --token "$(cat .env | grep JWT | cut -d'=' -f2)" --action list

# Kill port 3000
taskkill /IM node.exe /F

# Open Web Tracker
start http://localhost:3000/notification-tracker.html
```

---

**Created**: 2026-05-27  
**Status**: ✅ Ready for Use
