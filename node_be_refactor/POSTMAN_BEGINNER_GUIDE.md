# 📮 Postman - Hướng Dẫn Chi Tiết Cho Người Mới Bắt Đầu

**Bạn đã import collection rồi? Tuyệt! Bây giờ làm theo từng bước này.**

---

## 🎯 Mục Tiêu Của Bước Này

Bạn sẽ:
1. ✅ Login vào hệ thống (lấy token)
2. ✅ Xem danh sách notification hiện tại
3. ✅ Tạo một notification mới
4. ✅ Đánh dấu notification là đã đọc

**Thời gian: ~5 phút**

---

## 📍 BƯỚC 1: Mở Postman Collection

### Hình ảnh (text-based):

```
┌─────────────────────────────────────────┐
│ Postman Main Screen                     │
├─────────────────────────────────────────┤
│ Bên trái (Sidebar):                     │
│                                         │
│ Notification_System_API (collection)    │ ← Click đây
│  ├─ Authentication                      │
│  │  ├─ Register User                    │
│  │  └─ Login                            │
│  ├─ Notification - Retrieve             │
│  │  ├─ Get All Notifications            │
│  │  └─ Get Notifications (Page 2)       │
│  ├─ Notification - Create               │
│  ├─ Notification - Update               │
│  └─ FCM - Device Registration           │
│                                         │
└─────────────────────────────────────────┘
```

### Làm gì:
Nếu bạn thấy structure này ở sidebar trái → **OK!** ✅

Nếu không thấy:
1. Click menu "Collections" (bên trái)
2. Tìm "Notification_System_API"
3. Click vào

---

## 📍 BƯỚC 2: Setup Environment Variables

### Tại sao cần?
Variables giống như "biến lưu trữ" - bạn đặt giá trị 1 lần rồi dùng ở nhiều chỗ.

### Làm gì:

```
1. Bên phải Postman, tìm tab "Environment"
   (nếu không thấy, click ⚙️ → Environment)

2. Chọn: "Notification Testing" 
   (nếu chưa có, tạo environment mới)

3. Thêm các biến:
   
   Biến                      | Giá trị
   ─────────────────────────┼──────────────────────────
   base_url                  | http://localhost:3000/api/v1
   recipient_user_id         | (để trống lúc này)
   notification_id           | (để trống lúc này)
   
4. [Save]
```

### Kết quả:
```
✅ base_url = http://localhost:3000/api/v1
✅ Environment: "Notification Testing"
```

---

## 📍 BƯỚC 3: TEST LOGIN (BẢO MẬT)

### Tại sao cần login?
Vì token (JWT) là "chứng minh thân phận" bạn cần để làm bất kỳ việc gì.

### Làm gì:

**Step 3.1:** Mở request Login
```
Bên trái sidebar:
  Authentication
    └─ Login ← Click đây
```

**Step 3.2:** Xem màn hình request
```
┌──────────────────────────────────────────┐
│ TAB: Params | Headers | Body | ...       │
├──────────────────────────────────────────┤
│ POST http://localhost:3000/api/v1/auth/  │
│     login                                │
├──────────────────────────────────────────┤
│ Body (raw - JSON):                       │
│                                          │
│ {                                        │
│   "email": "test@example.com",          │
│   "password": "password123"              │
│ }                                        │
└──────────────────────────────────────────┘
```

**Step 3.3:** Nhập email/password thật
```
Nếu bạn có email/password của user:
  1. Chỉnh sửa email và password trong Body
  2. Nếu không có, dùng giá trị ở trên

Nếu user này chưa tồn tại:
  1. Phải Register trước (Authentication → Register User)
  2. Rồi mới Login
```

**Step 3.4:** Gửi request
```
Bên phải, tìm nút [Send] (màu xanh)
Click [Send] ← BỘM!
```

**Step 3.5:** Xem response (kết quả)
```
Response sẽ hiển thị ở phía dưới:

┌──────────────────────────────────────────┐
│ Status: 200 OK ✅                        │
├──────────────────────────────────────────┤
│ {                                        │
│   "success": true,                       │
│   "message": "Login successful",         │
│   "token": "eyJhbGciOiJIUzI1NiIsInR...",│ ← TOKEN!
│   "user": {                              │
│     "_id": "507f1f77bcf86cd799439011",  │
│     "name": "Tester",                    │
│     "email": "test@example.com",         │
│     "role": "CUSTOMER"                   │
│   }                                      │
│ }                                        │
└──────────────────────────────────────────┘

Status 200 = OK! ✅
Status 401 = Email/password sai ❌
Status 404 = Server không response ❌
```

---

## 🎉 IMPORTANT: Token Tự Động Lưu!

### Có gì đặc biệt?

Khi bạn click [Send] ở Login, **Postman tự động lưu token vào biến `jwt_token`!**

```
Trong response có:
  "token": "eyJhbGciOi..."
       ↓
Postman chạy script (phía sau):
  pm.environment.set('jwt_token', pm.response.json().token);
       ↓
Biến jwt_token được set tự động!
```

### Verify:
```
1. Click Tab "Environment"
2. Chọn "Notification Testing"
3. Tìm biến jwt_token
4. Nó phải có giá trị (không rỗng)

✅ Nếu có → Tuyệt!
❌ Nếu rỗng → Chạy Login lại
```

---

## 📍 BƯỚC 4: LẤY DANH SÁCH NOTIFICATION

### Mục tiêu:
Xem tất cả notification của bạn hiện tại.

### Làm gì:

**Step 4.1:** Mở request Get All Notifications
```
Sidebar:
  Notification - Retrieve
    └─ Get All Notifications ← Click
```

**Step 4.2:** Xem request
```
┌────────────────────────────────────────┐
│ GET                                    │
│ http://localhost:3000/api/v1/          │
│ notification?skip=0&limit=10           │
├────────────────────────────────────────┤
│ Headers:                               │
│   Authorization: Bearer {{jwt_token}}  │
│                                        │
│ No body needed                         │
└────────────────────────────────────────┘

Giải thích:
  skip=0    → Bắt đầu từ item thứ 0
  limit=10  → Lấy tối đa 10 items
  {{jwt_token}} → Tự động dùng token đã lưu
```

**Step 4.3:** Gửi request
```
Click [Send]
```

**Step 4.4:** Xem response
```
Response (status 200 OK):

{
  "success": true,
  "message": "Fetched successfully",
  "unreadCount": 3,              ← Bạn có 3 notification chưa đọc
  "items": [
    {
      "_id": "607f1f77bcf86cd799439070",
      "title": "Đặt sân thành công",
      "content": "Lịch đặt sân...",
      "type": "BOOKING",
      "isRead": false,
      "createdAt": "2026-05-27T10:15:00Z"
    },
    {
      "_id": "607f1f77bcf86cd799439071",
      "title": "Thanh toán thành công",
      "content": "Thanh toán...",
      "type": "PAYMENT",
      "isRead": false,
      "createdAt": "2026-05-27T10:14:00Z"
    }
  ],
  "total": 5,                    ← Tổng cộng 5 notification
  "skip": 0,
  "limit": 10
}
```

### Lưu ý:
```
Nếu "items" rỗng:
  → Không có notification
  → Đó là bình thường, chúng ta sẽ tạo một cái
```

---

## 📍 BƯỚC 5: TẠO NOTIFICATION MỚI

### Mục tiêu:
Tạo một notification test để xem nó hoạt động.

### CHUẨN BỊ:
```
Bạn cần biết ID của user khác để gửi notification cho người đó.

Cách lấy:
  1. Có file DB? Lấy _id của user bất kỳ
  2. Hoặc register user thứ 2 rồi dùng _id của nó
  3. Hoặc hỏi tôi!

Ví dụ: "607f1f77bcf86cd799439011"
       (ID này từ user khác)
```

**Thêm vào Environment:**
```
1. Tab Environment → Notification Testing
2. Biến: recipient_user_id
   Giá trị: (ID user khác)
3. [Save]
```

### Làm gì:

**Step 5.1:** Mở Create Notification request
```
Sidebar:
  Notification - Create
    └─ Create Booking Notification ← Click
```

**Step 5.2:** Xem request
```
┌────────────────────────────────────────┐
│ POST                                   │
│ http://localhost:3000/api/v1/          │
│ notification                           │
├────────────────────────────────────────┤
│ Headers:                               │
│   Authorization: Bearer {{jwt_token}}  │
│   Content-Type: application/json       │
├────────────────────────────────────────┤
│ Body (raw JSON):                       │
│                                        │
│ {                                      │
│   "userId": "{{recipient_user_id}}",  │
│   "title": "Đặt sân thành công",      │
│   "content": "Bạn đã đặt sân...",    │
│   "type": "BOOKING",                  │
│   "metadata": {                        │
│     "bookingId": "123456",            │
│     "link": "/bookings/123456"        │
│   }                                    │
│ }                                      │
└────────────────────────────────────────┘

Giải thích:
  userId → Người nhận (dùng biến)
  title → Tiêu đề
  content → Nội dung
  type → Loại (BOOKING, PAYMENT, SYSTEM, PROMOTION)
  metadata → Dữ liệu thêm (booking ID, link...)
```

**Step 5.3:** Chỉnh sửa nếu cần
```
Nếu muốn đổi nội dung:
  1. Click vào Body
  2. Sửa text
  3. Giữ {{recipient_user_id}} (đừng sửa)
```

**Step 5.4:** Gửi request
```
Click [Send]
```

**Step 5.5:** Xem response
```
Status 201 Created ✅

Response:
{
  "success": true,
  "message": "Notification created successfully",
  "notification": {
    "_id": "607f1f77bcf86cd799439072",
    "userId": "607f1f77bcf86cd799439011",
    "title": "Đặt sân thành công",
    "content": "Bạn đã đặt sân...",
    "type": "BOOKING",
    "metadata": {
      "bookingId": "123456",
      "link": "/bookings/123456"
    },
    "isRead": false,
    "createdAt": "2026-05-27T10:20:00Z"
  }
}

LƯU Ý ID này: "607f1f77bcf86cd799439072" ← Dùng cho bước sau
```

---

## 📍 BƯỚC 6: ĐÁNH DẤU NOTIFICATION ĐÃ ĐỌC

### Chuẩn Bị:
```
Lấy _id từ step 5.5 (response):
  "607f1f77bcf86cd799439072"

Thêm vào Environment:
  1. Tab Environment → Notification Testing
  2. Biến: notification_id
     Giá trị: 607f1f77bcf86cd799439072
  3. [Save]
```

### Làm gì:

**Step 6.1:** Mở Mark as Read request
```
Sidebar:
  Notification - Update
    └─ Mark Notification as Read ← Click
```

**Step 6.2:** Xem request
```
┌────────────────────────────────────────┐
│ PUT                                    │
│ http://localhost:3000/api/v1/          │
│ notification/{{notification_id}}/read  │
├────────────────────────────────────────┤
│ Headers:                               │
│   Authorization: Bearer {{jwt_token}}  │
│                                        │
│ Body: (rỗng - không cần gì)            │
└────────────────────────────────────────┘
```

**Step 6.3:** Gửi request
```
Click [Send]
```

**Step 6.4:** Xem response
```
Status 200 OK ✅

Response:
{
  "success": true,
  "message": "Notification marked as read",
  "notification": {
    "_id": "607f1f77bcf86cd799439072",
    "isRead": true,  ← Thay đổi từ false → true
    ...
  }
}
```

---

## 🔄 BƯỚC 7: VERIFY - KIỂM TRA LẠI

### Mục tiêu:
Xác nhận rằng notification đã được đánh dấu.

### Làm gì:

**Step 7.1:** Chạy lại "Get All Notifications"
```
Sidebar:
  Notification - Retrieve
    └─ Get All Notifications ← Click lại

Click [Send]
```

**Step 7.2:** Xem response
```
Trong response, tìm notification với ID vừa rồi:

{
  "items": [
    {
      "_id": "607f1f77bcf86cd799439072",
      "isRead": true,  ← ✅ Đã thay đổi thành true!
      ...
    }
  ]
}
```

---

## 🎯 TÓNG TẮTS - BẠN VỪA LÀMS:

```
BƯỚC 1: Mở Collection ✅
        ↓
BƯỚC 2: Setup Variables ✅
        ↓
BƯỚC 3: Login (lấy token) ✅
        ↓
BƯỚC 4: Xem danh sách notification ✅
        ↓
BƯỚC 5: Tạo notification mới ✅
        ↓
BƯỚC 6: Đánh dấu đã đọc ✅
        ↓
BƯỚC 7: Kiểm tra lại ✅

🎉 HOÀN THÀNH!
```

---

## 🆘 LỖI THƯỜNG GẶP VÀ CÁCH FIX

### ❌ "Unauthorized" hoặc "No token"

```
Nguyên nhân:
  - Chưa login hoặc token hết hạn
  - Header Authorization sai

Cách fix:
  1. Chạy Login request lại
  2. Kiểm tra jwt_token có giá trị không
  3. Verify Authorization header: "Bearer {{jwt_token}}"
  4. Chạy request lại
```

### ❌ "Cannot connect to localhost:3000"

```
Nguyên nhân:
  - Server không chạy

Cách fix:
  1. Terminal: npm run dev
  2. Đợi thấy "Server is running on port 3000"
  3. Thử request lại
```

### ❌ "Variable undefined {{base_url}}"

```
Nguyên nhân:
  - Environment không được set đúng

Cách fix:
  1. Kiểm tra dropdown Environment (phải chọn "Notification Testing")
  2. Kiểm tra biến base_url có giá trị
  3. Click [Save]
  4. Thử request lại
```

### ❌ "isRead: false" khi create

```
Nguyên nhân:
  - Bình thường! Notification mới luôn isRead = false
  
Cách fix:
  - Đó là đúng, dùng "Mark as Read" để đổi
```

---

## 💡 MẸO & TIPS

### Tip 1: Copy-Paste từ Response
```
Nếu muốn copy ID từ response:
  1. Chọn text ID
  2. Ctrl+C (copy)
  3. Tab Environment
  4. Paste vào biến
  5. [Save]

Nhanh hơn việc gõ tay!
```

### Tip 2: Dùng Tab "Pre-request Script"
```
Một số request có tab này:
  - Chạy code trước khi gửi request
  - Có thể dùng để validate data

Click vào xem có gì không!
```

### Tip 3: Xem Full Response JSON
```
Response quá to?
  1. Click vào response
  2. "Pretty" tab (phải)
  3. Sẽ format đẹp hơn
  4. Dễ đọc hơn
```

---

## 🎓 Tiếp Theo (Sau khi thành thạo)

Khi bạn làm thành thạo 7 bước trên:

1. **Thử các request khác:**
   - Register User
   - Create Payment Notification
   - Create System Notification
   - Mark All as Read

2. **Thử FCM (Firebase):**
   - Register FCM Token
   - Remove FCM Token

3. **Kiểm tra Pagination:**
   - Get Notifications (Page 2)
   - Thay đổi skip, limit

4. **Test với Web Tracker:**
   - Vừa test Postman vừa xem Web Tracker
   - Thấy real-time updates!

---

## 📝 Quick Reference

### Variables cần setup:
```
base_url             = http://localhost:3000/api/v1
jwt_token            = (auto-set sau Login)
current_user_id      = (auto-set sau Login)
recipient_user_id    = (set thủ công)
notification_id      = (copy từ response)
```

### Headers luôn cần:
```
Authorization: Bearer {{jwt_token}}
Content-Type: application/json (khi POST/PUT)
```

### Các loại notification:
```
type: "BOOKING"    (Đặt sân)
type: "PAYMENT"    (Thanh toán)
type: "SYSTEM"     (Thông báo hệ thống)
type: "PROMOTION"  (Khuyến mãi)
```

---

## ✅ Kiểm Tra Hoàn Thành

Nếu bạn làm xong 7 bước và thấy:
- ✅ Status 200/201
- ✅ success: true
- ✅ Notification hiển thị ở Get All
- ✅ isRead thay đổi được

→ **BẠN ĐÃ THÀNH THẠO POSTMAN!** 🎉

---

**Có câu hỏi?** Hỏi tôi ngay!  
**Không hiểu chỗ nào?** Chỉ rõ, tôi giải thích thêm!  

**Bây giờ, mở Postman và làm theo 7 bước nhé!** 🚀
