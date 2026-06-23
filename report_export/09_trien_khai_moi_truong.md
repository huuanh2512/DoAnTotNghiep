# 10. TRIỂN KHAI VÀ MÔI TRƯỜNG

## 10.1 Cấu trúc thư mục dự án tổng thể

```
MobileApp/
├── node_be_refactor/                # Backend Node.js/Express
│   ├── src/
│   │   ├── main.js                  # Entry point
│   │   ├── config/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── models/
│   │   ├── middlewares/
│   │   └── utils/
│   ├── package.json
│   └── .env                         # Không commit (biến môi trường)
│
├── sport_management/
│   └── sports_management/           # Flutter Mobile App
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── firebase_options.dart # Không commit (tự gen)
│       │   ├── injection/
│       │   └── router/
│       ├── modules/                  # Feature modules
│       ├── android/                  # Android configs, google-services.json
│       ├── ios/                      # iOS configs
│       └── pubspec.yaml
│
├── react-staff-admin/               # React Web Admin
│   ├── src/
│   │   ├── App.tsx
│   │   ├── core/
│   │   └── features/
│   ├── package.json
│   └── .env                         # Không commit
│
└── report_export/                   # Tài liệu báo cáo (output)
    ├── 00_tong_quan_du_an.md
    ├── 01_cong_nghe_kien_truc.md
    ├── ...
    └── REPORT_EXPORT_FULL.md
```

---

## 10.2 Backend Deployment

### Công nghệ server

| Thành phần | Công nghệ | Ghi chú |
|-----------|-----------|---------|
| Runtime | Node.js | v18+ khuyến nghị |
| Framework | Express.js | v4.x |
| Database | MongoDB | Atlas cloud hoặc self-hosted |
| Image Storage | Cloudinary | Free tier |
| Payment Gateway | ZaloPay | Sandbox hiện tại |
| Push Notification | Firebase FCM | Cần serviceAccountKey |
| Real-time | Socket.IO | Trên cùng Node.js server |
| Scheduler | node-cron | In-process, không cần queue bên ngoài |

### Biến môi trường Backend

> **Lưu ý**: Chỉ liệt kê TÊN biến và mục đích, không hiển thị giá trị.

| Biến | Mục đích |
|------|---------|
| `PORT` | Cổng chạy server (mặc định 3000) |
| `MONGODB_URI` | Connection string MongoDB Atlas |
| `JWT_SECRET` | Secret key ký Access Token |
| `JWT_REFRESH_SECRET` | Secret key ký Refresh Token |
| `JWT_EXPIRES_IN` | Thời gian hết hạn Access Token (vd: 15m) |
| `JWT_REFRESH_EXPIRES_IN` | Thời gian hết hạn Refresh Token (vd: 7d) |
| `CLOUDINARY_CLOUD_NAME` | Tên Cloudinary cloud |
| `CLOUDINARY_API_KEY` | API Key Cloudinary |
| `CLOUDINARY_API_SECRET` | API Secret Cloudinary |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_CLIENT_EMAIL` | Service account email Firebase |
| `FIREBASE_PRIVATE_KEY` | Private key Firebase |
| `ZALOPAY_APP_ID` | ZaloPay App ID (Sandbox) |
| `ZALOPAY_KEY1` | ZaloPay Key 1 |
| `ZALOPAY_KEY2` | ZaloPay Key 2 (verify callback) |
| `ZALOPAY_CALLBACK_URL` | URL backend nhận callback từ ZaloPay |
| `EMAIL_USER` | Email dùng gửi OTP (Nodemailer) |
| `EMAIL_PASSWORD` | Mật khẩu email (hoặc App Password Gmail) |
| `FRONTEND_URL` | URL frontend (CORS) |
| `NODE_ENV` | development/production |
| `AUTH_MODE` | jwt / firebase (chế độ xác thực) |

### Cách khởi động Backend

```bash
# Install dependencies
npm install

# Development (nodemon auto-restart)
npm run dev

# Production
npm start
```

**Scripts trong package.json**:
- `start`: `node src/main.js`
- `dev`: `nodemon src/main.js` (có thể)

### Health Check URLs

| URL | Mô tả |
|-----|-------|
| `GET /health` | Kiểm tra server có chạy không |
| `GET /health/cron` | Xem trạng thái 4 cron jobs |
| `GET /api/v1/health` | Health check API version |
| `GET /api/v1/tracker` | Danh sách tất cả API routes (dev tool) |
| `GET /api/v1/export` | Export API list dạng Markdown |

### Recommend deploy platform

1. **Render.com** (đang dùng, free tier): Cần UptimeRobot ping để tránh sleep, phù hợp dev/demo
2. **Railway.app**: Free tier tốt hơn Render, không sleep
3. **VPS (DigitalOcean, Vultr)** + PM2: Production grade, cần quản lý thủ công
4. **Heroku**: Paid, ổn định nhưng đắt hơn

**PM2 cho production** (khuyến nghị nếu dùng VPS):
```bash
pm2 start src/main.js --name sport-api
pm2 startup
pm2 save
```

---

## 10.3 Flutter Deployment

### Target platforms

- **Primary**: Android (APK / AAB)
- **Secondary**: iOS (kỹ thuật, chưa deploy)

### Biến môi trường / Config Flutter

| Config | File | Ghi chú |
|--------|------|---------|
| API Base URL | `lib/core/services/api_service.dart` | Hard-coded hoặc từ constants |
| Firebase Config | `lib/firebase_options.dart` | Tự sinh bởi `flutterfire configure`, không commit |
| `google-services.json` | `android/app/google-services.json` | Firebase Android, không commit |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` | Firebase iOS, không commit |
| ZaloPay App ID (client) | Trong payment service | Config client-side ZaloPay |

### Build Android

```bash
# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build AAB (upload lên Play Store)
flutter build appbundle --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Signing APK

Cần `key.jks` và cấu hình trong `android/app/build.gradle`:
```
storeFile = file('../key.jks')
storePassword = ***
keyAlias = ***
keyPassword = ***
```

### Firebase Setup Flutter

```bash
# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình (cần Firebase project)
flutterfire configure --project=your-firebase-project-id
```

Kết quả: `firebase_options.dart` được tự sinh, cần commit vào git nhưng không chứa private key.

### Minimum Android SDK

Từ pubspec.yaml và code, yêu cầu:
- `minSdkVersion`: 21 (Android 5.0 Lollipop)
- `targetSdkVersion`: 33+

### Packages quan trọng

| Package | Version | Mục đích |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `get_it` | ^8.0.2 | Dependency injection |
| `go_router` | ^14.2.0 | Routing |
| `dio` | ^5.7.0 | HTTP client |
| `flutter_secure_storage` | ^9.2.2 | Secure token storage |
| `firebase_core` | ^3.6.0 | Firebase core |
| `firebase_auth` | ^5.3.1 | Firebase authentication |
| `firebase_messaging` | ^15.1.3 | FCM push notification |
| `socket_io_client` | ^2.0.3 | Socket.IO client |
| `intl` | ^0.19.0 | Internationalization, date format |
| `image_picker` | ^1.1.2 | Chọn ảnh từ gallery/camera |
| `webview_flutter` | ^4.9.0 | ZaloPay WebView |
| `android_intent_plus` | ^5.2.0 | Deep link ZaloPay app |
| `dartz` | ^0.10.1 | Functional error handling |
| `flutter_local_notifications` | ^18.0.1 | Local notification |
| `table_calendar` | ^3.1.2 | Calendar widget đặt sân |

---

## 10.4 React Web Admin Deployment

### Build

```bash
# Install dependencies
npm install

# Development server
npm start   # http://localhost:3000

# Production build
npm run build   # Output: build/
```

### Deploy

- **Vercel** (khuyến nghị): `vercel deploy`
- **Netlify**: Drag-and-drop hoặc CI/CD
- **Nginx** + VPS: Serve static `build/` folder
- **Firebase Hosting**: `firebase deploy`

### Biến môi trường React

Cấu hình trong `.env` file (không commit):

| Biến | Mục đích |
|------|---------|
| `REACT_APP_API_BASE_URL` | URL backend API |
| `REACT_APP_SOCKET_URL` | URL Socket.IO server |
| `REACT_APP_FIREBASE_API_KEY` | Firebase Web API Key |
| `REACT_APP_FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain |
| `REACT_APP_FIREBASE_PROJECT_ID` | Firebase Project ID |
| Các REACT_APP_FIREBASE_* khác | Firebase config cho web |

### Packages quan trọng React

| Package | Version | Mục đích |
|---------|---------|---------|
| `react` | ^19.2.6 | UI framework |
| `typescript` | ^4.9.5 | Type safety |
| `antd` | ^6.4.3 | UI component library |
| `@tanstack/react-query` | ^5.100.14 | Server state management |
| `react-router-dom` | ^7.15.1 | Routing |
| `axios` | ^1.16.1 | HTTP client |
| `socket.io-client` | ^4.7.5 | Socket.IO client |
| `recharts` | ^3.8.1 | Charts/biểu đồ |
| `firebase` | ^11.10.0 | Firebase client SDK |
| `lucide-react` | ^1.16.0 | Icon library |
| `tailwindcss` | ^3.4.17 | CSS utility framework |

---

## 10.5 Sơ đồ triển khai đề xuất

```
┌──────────────────────────────────────────────────────────────────┐
│                     PRODUCTION DEPLOYMENT                         │
│                                                                    │
│  ┌──────────────┐   ┌──────────────────┐   ┌────────────────────┐ │
│  │  Flutter App │   │  React Web Admin │   │   UptimeRobot      │ │
│  │  (Android    │   │  (Vercel/Netlify)│   │   (keep-alive ping)│ │
│  │  APK/AAB)    │   │                  │   │                    │ │
│  └──────┬───────┘   └─────────┬────────┘   └────────┬───────────┘ │
│         │                     │                      │             │
│         └─────────────────────┼──────────────────────┘             │
│                               │ HTTPS + WSS                        │
│                               ▼                                    │
│                    ┌──────────────────────┐                        │
│                    │   Backend Node.js    │                        │
│                    │   (Render/Railway)   │                        │
│                    │   Port 3000          │                        │
│                    └────────────┬─────────┘                        │
│                                 │                                  │
│           ┌─────────────────────┼────────────────────────┐        │
│           │                     │                         │        │
│           ▼                     ▼                         ▼        │
│  ┌──────────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ MongoDB Atlas    │  │ Cloudinary   │  │ Firebase FCM        │  │
│  │ (Free M0 cluster)│  │ (Image CDN)  │  │ (Push Notification) │  │
│  └──────────────────┘  └──────────────┘  └─────────────────────┘  │
│                                                                    │
│           ┌────────────────────────────────────────────────┐      │
│           │                                                │      │
│           ▼                                                ▼      │
│  ┌───────────────────┐                        ┌──────────────────┐ │
│  │ ZaloPay Sandbox   │                        │ Gmail SMTP       │ │
│  │ (Payment)         │                        │ (OTP Email)      │ │
│  └───────────────────┘                        └──────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 10.6 Phân quyền và bảo mật triển khai

### CORS

Backend cấu hình CORS trong `main.js`:
- `FRONTEND_URL` trong env → whitelist cho React Web
- Mobile (Flutter): không bị CORS (native HTTP client)

### Firewall / Rate Limiting

- Hiện chưa cấu hình rate limiting tường minh trong code
- Nếu deploy Render → có thể cấu hình qua Render settings
- Khuyến nghị production: thêm `express-rate-limit`

### HTTPS

- Render/Railway/Vercel/Netlify tự cấp SSL certificate (Let's Encrypt)
- ZaloPay callback **bắt buộc HTTPS**

### MongoDB Security

- MongoDB Atlas có IP whitelist
- Connection string dùng user/password trong `MONGODB_URI`
- Không expose MongoDB port ra ngoài internet

---

## 10.7 Cấu hình CORS

Ví dụ cấu hình trong `main.js`:
```javascript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

Socket.IO CORS:
```javascript
const io = new Server(httpServer, {
  cors: {
    origin: process.env.FRONTEND_URL || '*',
    methods: ['GET', 'POST']
  }
});
```

---

## 10.8 Tình trạng triển khai hiện tại

| Thành phần | Môi trường | Trạng thái | Ghi chú |
|-----------|-----------|-----------|---------|
| Backend API | Render.com | ✅ Live (dev/demo) | Cần UptimeRobot tránh sleep |
| React Web Admin | Chưa xác định | ⚠️ Unknown | Cần deploy |
| Flutter APK | Local build | ⚠️ APK chạy được | Chưa publish lên Play Store |
| MongoDB | MongoDB Atlas | ✅ Free M0 cluster | Giới hạn 512MB storage |
| Cloudinary | Cloudinary Free | ✅ Active | Giới hạn 25GB bandwidth/tháng |
| Firebase FCM | Firebase Project | ⚠️ Cần serviceAccountKey | FCM có thể chưa hoạt động hoàn toàn |
| ZaloPay | Sandbox | ⚠️ Sandbox only | Cần merchant approval để production |
| Gmail OTP | Gmail SMTP | ✅ Cấu hình được | Cần App Password (2FA Gmail) |

**Ghi chú triển khai**:
> Toàn bộ hệ thống hiện tại phù hợp cho mục đích **demo/đồ án**. Để đưa vào production thực sự cần: ZaloPay merchant production credentials, Firebase serviceAccountKey production, tăng MongoDB lên M2+, cấu hình Redis cho Socket.IO multi-instance.
