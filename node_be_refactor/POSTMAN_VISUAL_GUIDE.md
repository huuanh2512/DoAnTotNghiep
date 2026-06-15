# 📮 Postman Quick Reference - Visual Guide

Hướng dẫn visual (text-based) sử dụng Postman Collection.

---

## 🎬 Step-by-Step Workflow

### STEP 1: Import Collection (30 giây)

```
┌─────────────────────────────────────────┐
│ Postman Main Screen                     │
├─────────────────────────────────────────┤
│ Click "Import" button                   │
│ ↓                                       │
│ Upload: Notification_System_API...json  │
│ ↓                                       │
│ [Import] button                         │
│ ↓                                       │
│ ✅ Collection imported successfully    │
└─────────────────────────────────────────┘
```

---

### STEP 2: Login (1 phút)

```
Collection Tree (left panel):
├── Authentication
│   ├── Register User
│   └── Login ← Click here
│
Request Tab:
┌─────────────────────────────┐
│ POST /auth/login            │
├─────────────────────────────┤
│ Headers: Content-Type: JSON │
│ Body:                       │
│ {                          │
│   "email": "test@exam.com" │
│   "password": "pass123"    │
│ }                          │
└─────────────────────────────┘
     ↓ [Send] button
┌─────────────────────────────┐
│ Response (200 OK):          │
│ {                          │
│   "success": true,         │
│   "token": "eyJ...",       │ ← Auto-saved!
│   "user": {_id: "..."}     │
│ }                          │
└─────────────────────────────┘
```

✅ **jwt_token tự động được set!**

---

### STEP 3: Get Notifications (2 phút)

```
Collection Tree:
├── Notification - Retrieve
│   ├── Get All Notifications ← Click
│   └── Get Notifications (Page 2)

Request:
┌──────────────────────────────────┐
│ GET /notification?skip=0&limit=10│
├──────────────────────────────────┤
│ Headers: Authorization: Bearer   │
│          {{jwt_token}}           │ ← Auto-filled
│                                  │
│ No body needed                   │
└──────────────────────────────────┘
     ↓ [Send]
┌──────────────────────────────────┐
│ Response (200 OK):               │
│ {                               │
│   "success": true,              │
│   "unreadCount": 3,             │
│   "items": [                    │
│     {                           │
│       "_id": "507f...",         │ ← Lưu ID này
│       "title": "...",           │
│       "isRead": false           │
│     }                           │
│   ],                            │
│   "total": 5                    │
│ }                               │
└──────────────────────────────────┘
```

---

### STEP 4: Create Test Notification (3 phút)

```
CHUẨN BỊ:
1. Mở tab "Environment" (bên trái)
2. Set variables:
   recipient_user_id = "ID_của_user_khác"
   (Lấy từ register user khác hoặc DB)

Collection Tree:
├── Notification - Create
│   ├── Create Booking Notification ← Click
│   ├── Create Payment Notification
│   ├── Create System Notification
│   └── Create Promotion Notification

Request:
┌────────────────────────────────────┐
│ POST /notification                 │
├────────────────────────────────────┤
│ Headers: Authorization: Bearer     │
│          {{jwt_token}}             │
│          Content-Type: application/│
│          json                      │
├────────────────────────────────────┤
│ Body (raw JSON):                   │
│ {                                  │
│   "userId": "{{recipient_user_id}}"│
│   "title": "Đặt sân thành công",  │
│   "content": "Lịch đặt sân...",   │
│   "type": "BOOKING",              │
│   "metadata": {                    │
│     "bookingId": "123456",        │
│     "link": "/bookings/123456"    │
│   }                                │
│ }                                  │
└────────────────────────────────────┘
     ↓ [Send]
✅ Notification created!
```

---

### STEP 5: Mark as Read (2 phút)

```
CHUẨN BỊ:
1. Lấy _id từ "Get All Notifications"
2. Set vào environment:
   notification_id = "507f1f77bcf86cd799439070"

Collection Tree:
├── Notification - Update
│   ├── Mark Notification as Read ← Click
│   └── Mark All Notifications as Read

Request:
┌──────────────────────────────────────┐
│ PUT /notification/{{notification_id}}│
│     /read                            │
├──────────────────────────────────────┤
│ Headers: Authorization: Bearer       │
│          {{jwt_token}}               │
│                                      │
│ Body: (empty)                        │
└──────────────────────────────────────┘
     ↓ [Send]
✅ Notification marked as read!
```

---

### STEP 6: Register FCM Token (2 phút)

```
Collection Tree:
├── FCM - Device Registration
│   ├── Register FCM Token ← Click
│   └── Remove FCM Token

Request:
┌──────────────────────────────────┐
│ POST /user/register-fcm          │
├──────────────────────────────────┤
│ Headers: Authorization: Bearer   │
│          {{jwt_token}}           │
│          Content-Type: application│
│          /json                   │
├──────────────────────────────────┤
│ Body (raw JSON):                 │
│ {                               │
│   "token": "eYdYc0JXOVJNRkM3..." │
│ }                               │
└──────────────────────────────────┘
     ↓ [Send]
✅ FCM token registered!
   fcmTokenCount: 1
```

---

## 📊 Environment Variables Setup

### Hình ảnh text:

```
┌─ Environment Tab ─────────────────────┐
│                                       │
│ Current: Notification Testing         │
│                                       │
│ VARIABLE         │ VALUE             │
├──────────────────┼──────────────────┤
│ base_url         │ http://localhost  │
│                  │ :3000/api/v1      │
├──────────────────┼──────────────────┤
│ jwt_token        │ eyJhbGciOiJIUzI1 │
│                  │ NiIs... (auto)    │
├──────────────────┼──────────────────┤
│ current_user_id  │ 607f1f77bcf86cd  │
│                  │ 799439011 (auto)  │
├──────────────────┼──────────────────┤
│ recipient_user_id│ (set manually)    │
├──────────────────┼──────────────────┤
│ notification_id  │ (set when needed) │
└──────────────────┴──────────────────┘

[Save]
```

---

## 🔑 Key Request Types

### 1️⃣ GET Requests (Read)

```
┌─────────────────────────────────┐
│ GET /notification               │
├─────────────────────────────────┤
│ Method: GET                     │
│ URL: {{base_url}}/notification  │
│                                 │
│ Headers:                        │
│   Authorization: Bearer {{jwt}} │
│                                 │
│ No Body                         │
│                                 │
│ Params:                         │
│   skip=0                        │
│   limit=10                      │
└─────────────────────────────────┘
```

---

### 2️⃣ POST Requests (Create)

```
┌────────────────────────────────┐
│ POST /notification             │
├────────────────────────────────┤
│ Method: POST                   │
│ URL: {{base_url}}/notification │
│                                │
│ Headers:                       │
│   Authorization: Bearer {{jwt}}│
│   Content-Type: application/..│
│   json                         │
│                                │
│ Body (raw JSON):               │
│ {                              │
│   "userId": "...",            │
│   "title": "...",             │
│   "content": "...",           │
│   "type": "BOOKING"           │
│ }                              │
└────────────────────────────────┘
```

---

### 3️⃣ PUT Requests (Update)

```
┌────────────────────────────────┐
│ PUT /notification/:id/read     │
├────────────────────────────────┤
│ Method: PUT                    │
│ URL: {{base_url}}/notification │
│      /{{notification_id}}/read │
│                                │
│ Headers:                       │
│   Authorization: Bearer {{jwt}}│
│                                │
│ Body: (empty)                  │
└────────────────────────────────┘
```

---

## 🎯 Complete Test Scenarios

### Scenario 1: Register & Login Flow

```
START
  ↓
┌─ Register User ──────────────────┐
│ POST /auth/register              │
│ Body: {email, password}          │
└──────────────────────────────────┘
  ↓
┌─ Login ──────────────────────────┐
│ POST /auth/login                 │
│ Body: {email, password}          │
│ Response: {token, user._id}      │
│ Auto-set: jwt_token              │
│ Auto-set: current_user_id        │
└──────────────────────────────────┘
  ↓
✅ READY TO TEST NOTIFICATIONS
```

---

### Scenario 2: Create & Fetch Notifications

```
START (after Login)
  ↓
┌─ Get All Notifications ──────────┐
│ Count: 0 (empty)                 │
└──────────────────────────────────┘
  ↓
┌─ Create Booking Notification ────┐
│ Recipient: {{recipient_user_id}} │
│ Type: BOOKING                    │
└──────────────────────────────────┘
  ↓
┌─ Get All Notifications ──────────┐
│ Count: 1 (new one appears!)      │
│ isRead: false                    │
│ Save _id → notification_id       │
└──────────────────────────────────┘
  ↓
┌─ Mark as Read ───────────────────┐
│ ID: {{notification_id}}          │
└──────────────────────────────────┘
  ↓
┌─ Get All Notifications ──────────┐
│ isRead: true (updated!)          │
└──────────────────────────────────┘
  ↓
✅ SUCCESS
```

---

### Scenario 3: Multiple Notification Types

```
Send BOOKING → Check
  ↓
Send PAYMENT → Check
  ↓
Send SYSTEM → Check
  ↓
Send PROMOTION → Check
  ↓
Get All Notifications (should see 4)
  ↓
Mark All as Read
  ↓
Verify all isRead = true
  ↓
✅ SUCCESS
```

---

## 💾 Using Response Data

### Copy ID from Response

```
Response JSON:
{
  "notification": {
    "_id": "607f1f77bcf86cd799439070" ← Copy này
  }
}

Steps:
1. Select text "607f1f77bcf86cd799439070"
2. Copy (Ctrl+C)
3. Click Environment tab
4. Paste into notification_id field
5. [Save]
```

---

## ✅ Verification Checklist

### After Each Request, Check:

```
┌─────────────────────────────────┐
│ Status Code                     │
├─────────────────────────────────┤
│ ✅ 200 - OK                     │
│ ✅ 201 - Created                │
│ ❌ 400 - Bad Request            │
│ ❌ 401 - Unauthorized           │
│ ❌ 403 - Forbidden              │
│ ❌ 404 - Not Found              │
│ ❌ 500 - Server Error           │
└─────────────────────────────────┘

Response Body:
├─ success: true/false
├─ message: (error/success text)
└─ data: (actual response)

Headers:
├─ Content-Type: application/json
├─ Date: ...
└─ Server: ...
```

---

## 🔄 Variables Auto-Set by Requests

```
┌──────────────────────────────────┐
│ Login Request → Auto-set:        │
├──────────────────────────────────┤
│ ✅ jwt_token                     │
│ ✅ current_user_id               │
└──────────────────────────────────┘

Script in "Tests" tab:
┌──────────────────────────────────┐
│ pm.environment.set(               │
│   'jwt_token',                   │
│   pm.response.json().token       │
│ );                               │
│                                  │
│ pm.environment.set(               │
│   'current_user_id',             │
│   pm.response.json().user._id    │
│ );                               │
└──────────────────────────────────┘
```

---

## 🚨 Common Errors & Fixes

### Error 1: "{{base_url}} undefined"

```
❌ Problem:
   URL shows: {{base_url}}/notification
   Error: variable not set

✅ Solution:
   1. Look at Environment dropdown
   2. Should say "Notification Testing"
   3. Click → Check base_url exists
   4. [Save] environment
```

### Error 2: "Unauthorized" (401)

```
❌ Problem:
   {
     "message": "Unauthorized: Missing token"
   }

✅ Solution:
   1. Re-run Login request
   2. Check jwt_token has value
   3. Check Authorization header:
      "Bearer {{jwt_token}}"
```

### Error 3: "ECONNREFUSED"

```
❌ Problem:
   Cannot connect to localhost:3000

✅ Solution:
   1. Check server running
      Terminal: npm run dev
   2. Check port 3000
      netstat -ano | findstr :3000
   3. Check base_url correct
```

---

## 📱 Mobile Preview (Responsive)

```
┌──────────────────┐
│ Postman Mobile   │
├──────────────────┤
│ Collections      │
│ ├─ Auth         │
│ ├─ Notification  │
│ └─ FCM           │
├──────────────────┤
│ [Send] button    │
├──────────────────┤
│ Response         │
│ (scroll)         │
└──────────────────┘
```

---

## 🎓 Learning Path

```
Day 1:
  → Learn to Import Collection
  → Test Login
  → Get Notifications

Day 2:
  → Create Notifications
  → Test All Types
  → Mark as Read

Day 3:
  → FCM Integration
  → Batch Testing
  → Advanced Features
```

---

## 📞 Need Help?

```
Problem? → Check:
  1. Server running?
  2. Collection imported?
  3. Variables set?
  4. Token valid?
  5. Base URL correct?
```

---

**Created**: 2026-05-27  
**Status**: ✅ Visual Guide Complete
