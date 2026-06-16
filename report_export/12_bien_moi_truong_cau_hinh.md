# 12. BIẾN MÔI TRƯỜNG VÀ CẤU HÌNH HỆ THỐNG

## 13.1 Backend Node.js – Biến môi trường (.env)

> ⚠️ **QUAN TRỌNG:** Không tiết lộ giá trị thực của các biến bên dưới. Chỉ liệt kê tên biến và mục đích.

| Tên biến | Mục đích | Bắt buộc | Ghi chú |
|----------|---------|---------|---------|
| `PORT` | Cổng HTTP server lắng nghe | Không | Mặc định 3000 |
| `MONGODB_URI` | Chuỗi kết nối MongoDB (connection string) | ✅ | Bao gồm username, password, cluster, database name |
| `JWT_SECRET` | Khóa bí mật để ký và xác thực JWT Access Token | ✅ | Tối thiểu 32 ký tự ngẫu nhiên |
| `JWT_REFRESH_SECRET` | Khóa bí mật để ký và xác thực JWT Refresh Token | ✅ | Khác với JWT_SECRET |
| `JWT_EXPIRES_IN` | Thời gian sống của Access Token | Không | VD: `15m`, `1h` |
| `JWT_REFRESH_EXPIRES_IN` | Thời gian sống của Refresh Token | Không | VD: `7d`, `30d` |
| `CLOUDINARY_CLOUD_NAME` | Tên cloud trên Cloudinary | ✅ | Lấy từ Cloudinary Dashboard |
| `CLOUDINARY_API_KEY` | API Key của Cloudinary | ✅ | Xác thực upload |
| `CLOUDINARY_API_SECRET` | API Secret của Cloudinary | ✅ | Xác thực upload |
| `EMAIL_USER` | Địa chỉ email dùng để gửi OTP | ✅ | Tài khoản Gmail hoặc SMTP |
| `EMAIL_PASS` | Mật khẩu ứng dụng (App Password) của email | ✅ | Không phải mật khẩu Gmail thông thường |
| `ZALOPAY_APP_ID` | App ID của tài khoản ZaloPay | ✅ | Lấy từ ZaloPay Developer Portal |
| `ZALOPAY_KEY1` | Key1 để ký HMAC tạo đơn hàng ZaloPay | ✅ | Bảo mật tuyệt đối |
| `ZALOPAY_KEY2` | Key2 để xác thực callback từ ZaloPay | ✅ | Bảo mật tuyệt đối |
| `ZALOPAY_ENDPOINT` | URL endpoint API ZaloPay | Không | Sandbox hoặc Production |
| `ZALOPAY_CALLBACK_URL` | URL callback ZaloPay gọi về sau khi thanh toán | ✅ | Phải là URL public (không phải localhost) |
| `NODE_ENV` | Môi trường chạy (`development` / `production`) | Không | Ảnh hưởng logging, error message |
| `FRONTEND_URL` | URL của React Web Admin (CORS) | Không | Cho phép cross-origin từ web admin |

### Cách cấu hình Firebase Admin SDK:
- Tải file `serviceAccountKey.json` từ Firebase Console → Project Settings → Service Accounts
- Đặt file tại `src/config/serviceAccountKey.json` (đã có template)
- **⚠️ TUYỆT ĐỐI KHÔNG commit file này lên git** – đã có trong `.gitignore`
- File này chứa thông tin xác thực của Firebase Project và có quyền admin

---

## 13.2 Flutter App – Cấu hình biến

| Tên biến / File | Nội dung | Mục đích |
|----------------|---------|---------|
| `lib/firebase_options.dart` | Cấu hình Firebase (apiKey, projectId, appId, messagingSenderId, storageBucket) | Khởi tạo Firebase SDK cho Flutter |
| `lib/core/network/` hoặc `server_module` | `BASE_URL` hoặc `baseUrl` | URL backend API (đổi khi deploy) |
| `GoogleService-Info.plist` | (iOS) | Cấu hình Firebase iOS – chưa có trong dự án |
| `google-services.json` | (Android) | Cấu hình Firebase Android |

> ⚠️ Các file `firebase_options.dart`, `google-services.json` chứa thông tin Firebase Project cụ thể. Không nên đưa vào báo cáo giá trị cụ thể.

---

## 13.3 React Web Admin – Cấu hình biến (.env)

| Tên biến | Mục đích | Ghi chú |
|----------|---------|---------|
| `REACT_APP_API_URL` hoặc tương đương | URL backend API | Sử dụng trong Axios base URL |

> Create React App sử dụng prefix `REACT_APP_` cho biến môi trường. Biến này được nhúng vào build tĩnh.

---

## 13.4 Deploy trên Render.com (Backend)

**Loại service:** Web Service (Node.js)

| Cấu hình | Giá trị |
|---------|---------|
| **Build Command** | `npm install` |
| **Start Command** | `node src/main.js` hoặc `npm start` |
| **Environment** | Node.js |
| **Tất cả biến môi trường** | Cấu hình trong Dashboard Render → Environment |

**Lưu ý quan trọng khi deploy lên Render Free Tier:**
1. Server sleep sau 15 phút không có request → Cron jobs bị tắt
2. Giải pháp: Đăng ký UptimeRobot (free) → Tạo monitor ping `/health` endpoint mỗi 5-10 phút
3. MongoDB Atlas cần thêm IP `0.0.0.0/0` vào whitelist (hoặc IP của Render) để kết nối được
4. ZALOPAY_CALLBACK_URL phải là URL của Render, không phải localhost

---

## 13.5 Deploy trên Render.com (React Web Admin)

**Loại service:** Static Site (React/CRA)

| Cấu hình | Giá trị |
|---------|---------|
| **Build Command** | `npm install && npm run build` |
| **Publish Directory** | `build` *(Create React App sinh ra `build/`, không phải `dist/`)* |
| **Rewrite Rule** | `/*` → `/index.html` (cho React Router) |

**Lưu ý:**
- Dự án sử dụng **Create React App** (react-scripts 5.0.1) → build directory là `build/`
- Nếu dùng Vite thì mới là `dist/` – dự án này KHÔNG dùng Vite

---

## 13.6 MongoDB Atlas – Cấu hình

| Cấu hình | Mô tả |
|---------|-------|
| **Cluster** | MongoDB Atlas (cloud) |
| **Authentication** | Username/Password trong connection string |
| **Network Access** | Thêm IP Render.com hoặc `0.0.0.0/0` để allow all |
| **Database Name** | Định nghĩa trong MONGODB_URI |
| **Indexes** | Tự động tạo qua Mongoose model definition khi server khởi động lần đầu |

---

## 13.7 Cloudinary – Cấu hình

| Cấu hình | Mô tả |
|---------|-------|
| **Mục đích** | Lưu ảnh avatar người dùng, ảnh cơ sở/sân |
| **Upload qua API** | `POST /api/v1/upload` (multipart/form-data, field `image`) |
| **Storage** | `multer-storage-cloudinary` adapter |
| **Middleware** | `upload.middleware.js` dùng `multer` |
| **Kết quả** | Trả về `secure_url` (HTTPS URL) để lưu vào DB |

---

## 13.8 Nodemailer – Cấu hình email OTP

| Cấu hình | Mô tả |
|---------|-------|
| **Mục đích** | Gửi OTP 6 số để reset mật khẩu |
| **Provider** | Gmail SMTP (hoặc Outlook) |
| **App Password** | Cần tạo Google App Password (2FA phải bật) |
| **OTP hết hạn** | Thời gian hết hạn lưu trong `resetPasswordOtpExpires` |
| **File** | `src/services/mail.service.js` |
