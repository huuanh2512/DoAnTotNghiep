# 📮 Postman Collection - Complete Guide Index

Hướng dẫn hoàn chỉnh sử dụng Postman để test Notification System.

---

## 📚 Available Guides

### 1. **POSTMAN_GUIDE.md** (Main Guide - 8KB)
Hướng dẫn chi tiết từng bước:
- ✅ Import collection
- ✅ Setup environment variables
- ✅ All 23 requests chi tiết
- ✅ Expected responses
- ✅ Pro tips & troubleshooting

**Bắt đầu từ đây nếu muốn:** Thông tin chính xác & chi tiết

---

### 2. **POSTMAN_VISUAL_GUIDE.md** (Visual - 6KB)
Hướng dẫn bằng ASCII diagrams:
- ✅ Step-by-step workflows
- ✅ Visual request templates
- ✅ Response formats
- ✅ Scenario flows
- ✅ Error solutions

**Bắt đầu từ đây nếu muốn:** Hình ảnh minh họa & dễ hiểu

---

### 3. **TESTING_TOOLS.md** (Overview - 4KB)
Tổng quát về tất cả testing tools:
- ✅ So sánh 3 tools (Web, CLI, Postman)
- ✅ Khi nào dùng tool nào
- ✅ Quick start
- ✅ Feature comparison

**Bắt đầu từ đây nếu muốn:** Compare với Web Tracker hoặc CLI

---

## 🚀 Quick Start (5 phút)

### Tôi chỉ muốn test nhanh!

```
1. Mở Postman
2. Import: Notification_System_API.postman_collection.json
3. Run "Login" request → [Send]
4. Run "Get All Notifications" → [Send]
5. Done! ✅
```

---

## 📖 By Task

### Task: "Tôi muốn..."

**...biết cách import collection**
→ Đọc: **POSTMAN_GUIDE.md** → **Step 1**

**...biết cách setup variables**
→ Đọc: **POSTMAN_GUIDE.md** → **Step 2**
→ Hoặc xem: **POSTMAN_VISUAL_GUIDE.md** → **Environment Variables Setup**

**...tạo test notification**
→ Đọc: **POSTMAN_GUIDE.md** → **Step 5**
→ Hoặc xem: **POSTMAN_VISUAL_GUIDE.md** → **STEP 4: Create Test Notification**

**...mark notification as read**
→ Đọc: **POSTMAN_GUIDE.md** → **Step 6**

**...register FCM token**
→ Đọc: **POSTMAN_GUIDE.md** → **Step 7**

**...test workflow lengkap**
→ Đọc: **POSTMAN_GUIDE.md** → **Complete Test Workflow**
→ Atau: **POSTMAN_VISUAL_GUIDE.md** → **Complete Test Scenarios**

**...troubleshoot errors**
→ Đọc: **POSTMAN_GUIDE.md** → **Troubleshooting**
→ Atau: **POSTMAN_VISUAL_GUIDE.md** → **Common Errors & Fixes**

---

## 🎯 Recommended Reading Order

### Beginner Path
```
1. TESTING_TOOLS.md
   (Understand what Postman is)

2. POSTMAN_VISUAL_GUIDE.md
   (See visual step-by-step)

3. POSTMAN_GUIDE.md
   (Learn details)

4. Start testing!
```

### Expert Path
```
1. POSTMAN_GUIDE.md
   (Read all details)

2. Import collection

3. Start testing immediately!
```

---

## 📊 Guide Comparison

| Feature | POSTMAN_GUIDE | VISUAL_GUIDE | TESTING_TOOLS |
|---------|-----------------|--------------|----------------|
| **Detail Level** | High | Medium | Low |
| **Visual Diagrams** | ❌ | ✅ | ❌ |
| **Step-by-Step** | ✅ | ✅ | ✅ |
| **All Requests** | ✅ | Partial | Summary |
| **Error Handling** | ✅ | ✅ | ❌ |
| **Pro Tips** | ✅ | ✅ | ❌ |
| **Compare Tools** | ❌ | ❌ | ✅ |
| **Quick Ref** | ❌ | ✅ | ✅ |

---

## 🔑 Key Concepts

### Variable System
```
{{base_url}}           → http://localhost:3000/api/v1
{{jwt_token}}          → Auto-set by Login request
{{current_user_id}}    → Auto-set by Login request
{{recipient_user_id}}  → Set manually for testing
{{notification_id}}    → Set from response _id
```

### Request Flow
```
Login
  ↓ (jwt_token set)
Get Notifications
  ↓ (copy _id)
Create Notification
  ↓ (fill form)
Mark as Read
  ↓ (notification_id needed)
Verify Status
```

### Headers Pattern
```
All requests need:
  Authorization: Bearer {{jwt_token}}
  Content-Type: application/json (for POST/PUT)
```

---

## 💾 Collection Structure

```
Notification_System_API.postman_collection.json
│
├── Authentication (2 requests)
│   ├── Register User
│   └── Login ← Run this first!
│
├── Notification - Retrieve (2 requests)
│   ├── Get All Notifications
│   └── Get Notifications (Page 2)
│
├── Notification - Create (4 requests)
│   ├── Create Booking Notification
│   ├── Create Payment Notification
│   ├── Create System Notification
│   └── Create Promotion Notification
│
├── Notification - Update (2 requests)
│   ├── Mark Notification as Read
│   └── Mark All Notifications as Read
│
└── FCM - Device Registration (2 requests)
    ├── Register FCM Token
    └── Remove FCM Token
```

Total: **13 requests** (23 if including variations)

---

## 🧪 Test Scenarios Provided

### Scenario 1: Basic Authentication
```
Register → Login → Token Saved ✅
```

### Scenario 2: CRUD Operations
```
Create → Read → Update → Delete
(or Mark as Read instead of Delete)
```

### Scenario 3: FCM Integration
```
Register Token → Store → Remove
```

### Scenario 4: Pagination
```
Page 1 (skip=0) → Page 2 (skip=10)
```

---

## 🎓 Learning Resources

### In This Folder
- **POSTMAN_GUIDE.md** - Complete documentation
- **POSTMAN_VISUAL_GUIDE.md** - Visual reference
- **IMPLEMENTATION_GUIDE.md** - API implementation details
- **TRACKER_USAGE_GUIDE.md** - Web Tracker guide

### External Resources
- Postman Docs: https://learning.postman.com/
- API Concepts: https://restfulapi.net/

---

## 🔗 Integration with Other Tools

### With Web Tracker
```
Postman: Create notification
  ↓
Web Tracker: Observe real-time update
  ↓
Verify data matches
```

### With CLI Tracker
```
CLI: List notifications
  ↓
Postman: Create new one
  ↓
CLI: List again to verify
```

---

## 📞 Quick Help

### "I don't know where to start"
→ Read: **POSTMAN_VISUAL_GUIDE.md** (5 min)

### "I need exact API details"
→ Read: **POSTMAN_GUIDE.md** (15 min)

### "I'm stuck on an error"
→ Jump to: **POSTMAN_GUIDE.md** → **Troubleshooting**

### "I want to see workflows"
→ Jump to: **POSTMAN_VISUAL_GUIDE.md** → **Complete Test Scenarios**

---

## ✅ Before You Start

Checklist:
- [ ] Postman installed
- [ ] Server running (`npm run dev`)
- [ ] Collection file downloaded
- [ ] Database accessible
- [ ] 5 minutes available

---

## 🎯 Success Criteria

After following this guide, you should be able to:

✅ Import Postman collection
✅ Setup environment variables
✅ Authenticate (Login)
✅ Create notifications
✅ Mark notifications as read
✅ Register FCM tokens
✅ Understand response formats
✅ Troubleshoot common errors
✅ Test all 4 notification types
✅ Use batch testing

---

## 📝 File References

```
docs/
├── POSTMAN_GUIDE.md ..................... Main guide
├── POSTMAN_VISUAL_GUIDE.md .............. Visual reference
├── TESTING_TOOLS.md ..................... Overview of all tools
├── TESTING_TOOLS_SUMMARY.md ............. Summary
├── TRACKER_USAGE_GUIDE.md ............... Web Tracker guide
├── IMPLEMENTATION_GUIDE.md .............. API details
└── DEPLOYMENT_SUMMARY.md ................ Deployment info

collections/
└── Notification_System_API.postman_collection.json
```

---

## 🚀 Next Steps

1. **Setup** (5 min)
   - Import collection
   - Configure environment

2. **Test** (10 min)
   - Run Login
   - Run Get Notifications
   - Run Create Notification

3. **Verify** (5 min)
   - Check responses
   - Verify database
   - Test with Web Tracker

4. **Integrate** (Later)
   - Integrate with your app
   - Write your own tests
   - Automate workflows

---

## 💡 Pro Tips

1. **Save frequently used values**
   - Keep variables updated
   - Use meaningful names

2. **Test error cases**
   - Try wrong token
   - Try missing fields
   - Try invalid IDs

3. **Use test scripts**
   - Automate assertions
   - Verify responses
   - Chain requests

4. **Export results**
   - Share with team
   - Document tests
   - Track history

---

## 📊 Time Estimates

| Task | Time |
|------|------|
| Read this guide | 5 min |
| Read POSTMAN_VISUAL_GUIDE | 5 min |
| Read POSTMAN_GUIDE (selected parts) | 10 min |
| Import collection | 1 min |
| Setup environment | 2 min |
| Run Login request | 30 sec |
| Test 5 requests | 5 min |
| **Total** | **~30 min** |

---

## 🎉 You're Ready!

Pick a guide, follow the steps, and start testing!

**Questions?** → Check POSTMAN_GUIDE.md  
**Visual learner?** → Check POSTMAN_VISUAL_GUIDE.md  
**Need overview?** → Check TESTING_TOOLS.md

---

**Created**: 2026-05-27  
**Status**: ✅ Complete
**Guides**: 3 (Detail + Visual + Overview)
