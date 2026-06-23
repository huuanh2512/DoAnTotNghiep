# 2. CÔNG NGHỆ VÀ KIẾN TRÚC

## 2.1 Công nghệ sử dụng

### Flutter / Dart
- **Vai trò**: Xây dựng ứng dụng mobile đa nền tảng (Android chính, iOS về kỹ thuật)
- **File chứng minh**: `pubspec.yaml` — `flutter: sdk: flutter`, `flutter_bloc: ^8.1.6`
- **Phiên bản SDK**: Dart `^3.12.0`, Flutter Material Design
- **Ưu điểm**: Single codebase cho Android & iOS, widget-based UI linh hoạt, BLoC pattern giúp tách biệt business logic và UI
- **Hạn chế**: App size lớn hơn native, webview ZaloPay cần thư viện bổ sung

### React / TypeScript
- **Vai trò**: Web Admin dashboard cho STAFF và ADMIN
- **File chứng minh**: `package.json` — `react: ^19.2.6`, `typescript: ^4.9.5`
- **Thư viện UI**: Ant Design (`antd: ^6.4.3`), TailwindCSS (`tailwindcss: ^3.4.17`)
- **State/Data**: TanStack React Query (`@tanstack/react-query: ^5.100.14`)
- **Ưu điểm**: TypeScript giúp type-safe, Ant Design có sẵn nhiều component admin phù hợp, React Query tối ưu cache/fetch
- **Hạn chế**: Bundle size lớn do Ant Design, cần cấu hình build tối ưu

### Node.js / Express
- **Vai trò**: RESTful API backend, xử lý toàn bộ business logic
- **File chứng minh**: `package.json` — `express: ^4.19.2`, `main: src/main.js`
- **Ưu điểm**: Non-blocking I/O phù hợp xử lý nhiều request đồng thời, hệ sinh thái npm phong phú
- **Hạn chế**: Single-threaded, cần cluster hoặc PM2 khi scale

### MongoDB / Mongoose
- **Vai trò**: Cơ sở dữ liệu NoSQL lưu toàn bộ dữ liệu hệ thống
- **File chứng minh**: `package.json` — `mongoose: ^8.24.0`, `src/config/mongo.js`
- **Ưu điểm**: Schema linh hoạt phù hợp hệ thống booking có nhiều nested subdocument (slot_config, matching_config, exception_dates); index phong phú tối ưu query
- **Hạn chế**: Không hỗ trợ ACID transaction đầy đủ như RDBMS (Mongoose session transactions có nhưng phức tạp hơn)

### Firebase Admin / FCM
- **Vai trò**: Gửi push notification qua Firebase Cloud Messaging, xác thực email
- **File chứng minh**: `package.json` — `firebase-admin: ^13.10.0`, `src/config/firebase-admin.js`
- **Flutter side**: `firebase_core: ^3.6.0`, `firebase_auth: ^5.3.1`, `firebase_messaging: ^15.1.3`
- **Chú ý**: Cần `serviceAccountKey.json` để hoạt động (có template tại `src/config/serviceAccountKey.json.template`), chưa cấu hình production key
- **Ưu điểm**: Độ tin cậy cao, miễn phí cho lượng thông báo vừa phải
- **Hạn chế**: Cần serviceAccountKey production để deploy thật

### Socket.IO
- **Vai trò**: Realtime notification trong app — thông báo ngay khi booking được duyệt, matching session cập nhật
- **File chứng minh**: `package.json` — `socket.io: ^4.7.2`, `src/services/socket-io.service.js`
- **Flutter side**: `socket_io_client: ^2.0.3` trong pubspec.yaml
- **React side**: `socket.io-client: ^4.7.5` trong package.json
- **Events**: `notification_received`, `new_notification`, `matching_session_updated`, `join_matching_room`, `leave_matching_room`, `ping/pong`
- **Ưu điểm**: Realtime, fallback về polling nếu WebSocket không hỗ trợ
- **Hạn chế**: Sticky session cần thiết khi scale horizontally

### JWT (JSON Web Token)
- **Vai trò**: Xác thực và phân quyền API
- **File chứng minh**: `package.json` — `jsonwebtoken: ^9.0.3`, `src/middlewares/auth.middleware.js`
- **Cơ chế**: Access Token + Refresh Token, verify trong mỗi request
- **Ưu điểm**: Stateless, dễ scale
- **Hạn chế**: Token revocation phức tạp (cần blacklist hoặc short expiry)

### Cloudinary
- **Vai trò**: Upload và lưu trữ ảnh (avatar, ảnh cơ sở)
- **File chứng minh**: `package.json` — `cloudinary: ^1.41.3`, `multer-storage-cloudinary: ^4.0.0`
- **Ưu điểm**: CDN toàn cầu, transform ảnh on-the-fly
- **Hạn chế**: Free tier giới hạn dung lượng

### node-cron
- **Vai trò**: Lên lịch các tác vụ tự động theo thời gian
- **File chứng minh**: `package.json` — `node-cron: ^4.2.1`
- **Các cron đang chạy**: auto-cancel-bookings, auto-complete-bookings, matchmaker, fixed-scheduler
- **Ưu điểm**: Đơn giản, không cần queue bên ngoài
- **Hạn chế**: Single-server, nếu server restart giữa chừng job có thể bỏ lỡ; không phù hợp khi scale multi-instance

### ZaloPay SDK
- **Vai trò**: Thanh toán trực tuyến qua cổng ZaloPay (Sandbox hiện tại)
- **File chứng minh**: `src/services/zalopay.service.js`, `src/controllers/zalopay.controller.js`, `android_intent_plus`, `webview_flutter` trong pubspec.yaml
- **Cơ chế**: Tạo order → redirect deeplink/webview → ZaloPay callback → cập nhật payment
- **Ưu điểm**: Phổ biến tại Việt Nam
- **Hạn chế**: Đang dùng Sandbox, cần merchant credentials production để go-live

### Nodemailer
- **Vai trò**: Gửi email OTP xác thực khi đăng ký
- **File chứng minh**: `package.json` — `nodemailer: ^8.0.10`, `src/services/mail.service.js`

### bcrypt
- **Vai trò**: Hash mật khẩu người dùng
- **File chứng minh**: `package.json` — `bcrypt: ^6.0.0`

### get_it (Flutter)
- **Vai trò**: Dependency Injection container
- **File chứng minh**: `pubspec.yaml` — `get_it: ^8.0.2`, `lib/injection/`

### go_router (Flutter)
- **Vai trò**: Routing khai báo cho Flutter app
- **File chứng minh**: `pubspec.yaml` — `go_router: ^14.2.0`, `lib/router/route_paths.dart`

### dio (Flutter)
- **Vai trò**: HTTP client cho Flutter, thay thế http package
- **File chứng minh**: `pubspec.yaml` — `dio: ^5.7.0`

### flutter_secure_storage (Flutter)
- **Vai trò**: Lưu trữ an toàn Access Token, Refresh Token
- **File chứng minh**: `pubspec.yaml` — `flutter_secure_storage: ^9.2.2`

### Recharts (React)
- **Vai trò**: Vẽ biểu đồ báo cáo doanh thu, hiệu suất sân
- **File chứng minh**: `package.json` — `recharts: ^3.8.1`

### dartz (Flutter)
- **Vai trò**: Functional programming types (Either, Option) để xử lý lỗi trong domain layer
- **File chứng minh**: `pubspec.yaml` — `dartz: ^0.10.1`

---

## 2.2 Kiến trúc tổng thể

Hệ thống được xây dựng theo mô hình kiến trúc **Client-Server đa tầng** với các thành phần độc lập có thể mở rộng riêng lẻ:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                                  │
│  ┌────────────────────┐          ┌─────────────────────────────────┐ │
│  │   Flutter Android  │          │    React Web Admin              │ │
│  │  (CUSTOMER + một   │          │    (ADMIN + STAFF)              │ │
│  │  phần STAFF/ADMIN) │          │    TypeScript + Ant Design      │ │
│  │  BLoC/Cubit, dio,  │          │    TanStack Query, Recharts     │ │
│  │  go_router, get_it │          │    React Router DOM v7          │ │
│  └────────┬───────────┘          └─────────────┬───────────────────┘ │
└───────────┼──────────────────────────────────── ┼───────────────────┘
            │ HTTPS REST API                       │ HTTPS REST API
            │ WebSocket (Socket.IO)                │ WebSocket (Socket.IO)
            ▼                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        BACKEND LAYER                                 │
│  Node.js + Express.js (RESTful API)                                  │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Routes → Controllers → Services → Repositories → Models        │ │
│  ├─────────────────────────────────────────────────────────────────┤ │
│  │  Middlewares: JWT Auth, Role Guard, Multer Upload                │ │
│  ├─────────────────────────────────────────────────────────────────┤ │
│  │  Cron Jobs: AutoCancel | AutoComplete | Matchmaker | FixedSched │ │
│  ├─────────────────────────────────────────────────────────────────┤ │
│  │  Socket.IO: Realtime Notification Service                        │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└───────────────────┬────────────────┬────────────────────────────────┘
                    │                │
         ┌──────────▼──────┐  ┌─────▼──────────┐
         │   MongoDB        │  │  Firebase Admin │
         │  (Mongoose ODM)  │  │  FCM + Auth     │
         └──────────────────┘  └────────────────┘
                    │
         ┌──────────▼──────┐
         │   Cloudinary     │
         │  (Image Storage) │
         └──────────────────┘
                    │
         ┌──────────▼──────┐
         │   ZaloPay        │
         │  (Payment Gate)  │
         └──────────────────┘
```

**Mô tả luồng hoạt động tổng quát:**
1. Client (Flutter/React) gửi HTTPS request đến Backend API (`/api/v1/...`)
2. Middleware JWT xác thực token, middleware Role Guard kiểm tra quyền
3. Controller nhận request, gọi Service xử lý business logic
4. Service gọi Repository để thao tác MongoDB qua Mongoose
5. Kết quả trả về JSON response chuẩn hóa
6. Các sự kiện quan trọng (booking confirmed, matching updated) kích hoạt Socket.IO emit đến client đang kết nối
7. FCM push notification được gửi đến thiết bị mobile qua Firebase Admin SDK
8. Cron jobs chạy định kỳ để tự động hóa: hủy booking quá hạn, hoàn thành booking đã qua giờ, ghép trận tự động, sinh lịch cố định

---

## 2.3 Kiến trúc Backend

**Pattern**: Controller → Service → Repository → Model (phân lớp rõ ràng)

### Cây thư mục Backend (rút gọn)
```
node_be_refactor/
├── src/
│   ├── main.js                          # Entry point, khởi tạo Express + Socket.IO + Cron
│   ├── config/
│   │   ├── mongo.js                     # Kết nối MongoDB
│   │   ├── firebase-admin.js            # Khởi tạo Firebase Admin SDK
│   │   └── auth-mode.js                 # Chế độ xác thực (JWT/Firebase)
│   ├── routes/
│   │   ├── index.js                     # Router tổng hợp, tự động map file .routes.js
│   │   ├── auth.routes.js               # POST /register, /sign-in, /verify-email...
│   │   ├── booking.routes.js            # CRUD booking, /cancel, /status
│   │   ├── court.routes.js              # CRUD court, slot-config
│   │   ├── court-blocks.routes.js       # Quản lý block/bảo trì sân
│   │   ├── facility.routes.js           # CRUD facility
│   │   ├── fixed-schedule.routes.js     # Lịch cố định: approve, reject, pause, resume...
│   │   ├── matching.routes.js           # Session, queue join/leave, member update
│   │   ├── notification.routes.js       # Danh sách, đánh dấu đã đọc
│   │   ├── payment.routes.js            # CRUD payment, update status
│   │   ├── reports.routes.js            # advanced-performance, court-performance
│   │   ├── review.routes.js             # CRUD review
│   │   ├── sport.routes.js              # CRUD sport
│   │   ├── upload.routes.js             # Upload ảnh Cloudinary
│   │   ├── user.routes.js               # Profile, role, status, FCM token
│   │   └── zalopay.routes.js            # create-order, query, callback
│   ├── controllers/                     # Nhận request, validate, gọi service
│   │   ├── auth.controller.js
│   │   ├── booking.controller.js
│   │   ├── court-blocks.controller.js
│   │   ├── court.controller.js
│   │   ├── facility.controller.js
│   │   ├── fcm.controller.js
│   │   ├── fixed-schedule.controller.js
│   │   ├── matching.controller.js
│   │   ├── notification.controller.js
│   │   ├── payment.controller.js
│   │   ├── reports.controller.js
│   │   ├── review.controller.js
│   │   ├── sport.controller.js
│   │   ├── upload.controller.js
│   │   ├── user.controller.js
│   │   └── zalopay.controller.js
│   ├── services/                        # Business logic
│   │   ├── booking.service.js           # (38KB) Booking lifecycle, conflict check, auto cancel/complete
│   │   ├── booking-price.service.js     # Tính giá booking theo slot
│   │   ├── court-availability.service.js# Kiểm tra availability của sân
│   │   ├── court-block.service.js       # Quản lý block/bảo trì
│   │   ├── court.service.js             # CRUD court + slot config
│   │   ├── facility.service.js          # CRUD facility + staff assignment
│   │   ├── fcm.service.js               # Gửi FCM notification
│   │   ├── fixed-schedule.service.js    # (77KB) Fixed schedule logic, booking generation
│   │   ├── mail.service.js              # Gửi email OTP
│   │   ├── matching.service.js          # (70KB) Matching session, queue, auto-match algorithm
│   │   ├── notification.helper.js       # Helper tạo notification + socket emit
│   │   ├── notification.service.js      # CRUD notification
│   │   ├── payment.service.js           # Payment state machine, ZaloPay integration
│   │   ├── report.service.js            # (41KB) Tổng hợp báo cáo doanh thu, hiệu suất
│   │   ├── review.service.js            # CRUD review
│   │   ├── socket-io.service.js         # Socket.IO events, room management
│   │   ├── sport.service.js             # CRUD sport
│   │   ├── upload.service.js            # Cloudinary upload
│   │   ├── user-auth.service.js         # Đăng ký, đăng nhập, OTP, JWT
│   │   ├── user-schedule-conflict.service.js # Kiểm tra conflict lịch của user
│   │   ├── user.service.js              # CRUD user profile
│   │   └── zalopay.service.js           # ZaloPay API integration
│   ├── repositories/                    # Truy vấn MongoDB
│   │   ├── booking.repository.js
│   │   ├── court.repository.js
│   │   ├── facility.repository.js
│   │   ├── fixed-schedule.repository.js
│   │   ├── match-queue.repository.js
│   │   ├── matching.repository.js
│   │   ├── notification.repository.js
│   │   ├── payment.repository.js
│   │   ├── review.repository.js
│   │   ├── sport.repository.js
│   │   └── user.repository.js
│   ├── models/                          # Mongoose Schema
│   │   ├── user.model.js
│   │   ├── facility.model.js
│   │   ├── sport.model.js
│   │   ├── court.model.js               # Bao gồm SlotConfig + CourtSlot
│   │   ├── court-block.model.js
│   │   ├── booking.model.js
│   │   ├── payment.model.js
│   │   ├── notification.model.js
│   │   ├── matching.model.js            # MatchingSession + Member + Team
│   │   ├── match-queue.model.js
│   │   ├── fixed-schedule.model.js      # FixedSchedule + ExceptionDate + MatchingConfig
│   │   └── review.model.js
│   ├── middlewares/
│   │   ├── auth.middleware.js           # verifyToken, requireRole
│   │   └── upload.middleware.js         # Multer + Cloudinary
│   └── utils/
│       ├── booking-time.util.js         # Xử lý thời gian booking (minutes)
│       ├── cron-auto-cancel-bookings.js # Cron: */1 * * * * — hủy PENDING quá hạn
│       ├── cron-auto-complete-bookings.js # Cron: */1 * * * * — hoàn thành booking đã qua giờ
│       ├── cron-fixed-scheduler.js      # Cron: 5 0 * * * — sinh booking lịch cố định
│       ├── cron-matchmaker.js           # Cron: */1 * * * * — ghép trận tự động
│       ├── cron-status.js               # Tracking trạng thái cron jobs
│       └── response.util.js             # Chuẩn hóa response format
└── package.json
```

---

## 2.4 Kiến trúc Flutter

**Pattern**: Clean Architecture với BLoC/Cubit, tổ chức theo Feature Module

### Cây thư mục Flutter (rút gọn)
```
sport_management/sports_management/
├── lib/
│   ├── main.dart                        # Entry point, khởi tạo Firebase, DI
│   ├── app.dart                         # MaterialApp, theme, GoRouter
│   ├── firebase_options.dart            # Firebase config (tự sinh)
│   ├── core/
│   │   ├── services/                    # ApiService (Dio), SocketIO service
│   │   ├── theme/                       # AppTheme, colors, typography
│   │   └── widgets/                     # Shared widgets
│   ├── injection/                       # get_it DI container setup
│   └── router/
│       ├── app_router.dart              # GoRouter configuration
│       └── route_paths.dart             # Route path constants
├── modules/                             # Feature modules (độc lập)
│   ├── app_module/                      # Shell/navigation
│   ├── authentication_module/
│   │   └── lib/
│   │       ├── application/             # BLoC/Cubit
│   │       ├── data/                    # Repository impl, API datasource
│   │       ├── domain/                  # Entities, Use cases, Repo interfaces
│   │       └── presentation/
│   │           ├── blocs/               # AuthBloc
│   │           ├── pages/
│   │           │   ├── sign_in_page.dart
│   │           │   ├── sign_up_page.dart
│   │           │   ├── verify_email_page.dart
│   │           │   └── reset_password_page.dart
│   │           └── routes/
│   ├── booking_module/
│   │   └── lib/
│   │       ├── application/             # Cubit
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── cubit/               # BookingCubit
│   │           ├── pages/
│   │           │   ├── booking_catalog_full_page.dart
│   │           │   ├── booking_detail_page.dart
│   │           │   ├── booking_history_page.dart
│   │           │   └── court_booking_page.dart    # (65KB - màn hình đặt sân chính)
│   │           ├── routes/
│   │           ├── utils/
│   │           └── widgets/
│   ├── matching_module/
│   │   └── lib/
│   │       ├── data/
│   │       ├── di/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── bloc/                # MatchingBloc
│   │           ├── pages/
│   │           │   ├── auto_matching_lobby_page.dart
│   │           │   ├── create_matching_session_page.dart  # (85KB)
│   │           │   ├── matching_detail_page.dart
│   │           │   └── matching_explorer_page.dart
│   │           ├── routes/
│   │           └── widgets/
│   ├── payment_module/
│   │   └── lib/
│   │       ├── application/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── cubit/
│   │           └── pages/
│   │               ├── invoice_detail_page.dart   # (83KB - trang hóa đơn chi tiết)
│   │               ├── mock_payment_page.dart
│   │               ├── payment_tab_widget.dart
│   │               └── zalopay_webview_page.dart
│   ├── home_module/
│   │   └── lib/presentation/
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   ├── customer_dashboard_section.dart  # (45KB)
│   │       │   ├── staff_dashboard_section.dart     # (114KB - màn hình staff lớn nhất)
│   │       │   ├── admin_dashboard_section.dart     # (30KB)
│   │       │   ├── admin_booking_supervision_page.dart
│   │       │   ├── admin_moderation_page.dart
│   │       │   ├── admin_payment_supervision_page.dart
│   │       │   ├── staff_court_report_page.dart
│   │       │   ├── staff_court_slot_config_page.dart
│   │       │   ├── staff_court_slot_config_detail_page.dart
│   │       │   ├── staff_personal_information_page.dart
│   │       │   └── system_settings_page.dart
│   │       └── account/
│   ├── notification_module/
│   │   └── lib/presentation/
│   │       ├── cubit/                   # NotificationCubit
│   │       └── widgets/                 # NotificationListWidget
│   ├── facility_module/                 # Màn hình xem cơ sở/sân cho CUSTOMER
│   ├── user_management_module/          # Quản lý profile
│   │   └── lib/presentation/
│   │       └── pages/                   # ProfilePage, AccountPage
│   ├── review_module/                   # Đánh giá sân
│   └── server_module/                   # ApiService, endpoints constants
└── pubspec.yaml
```

---

## 2.5 Kiến trúc React Web Admin

**Pattern**: Feature-based với Clean Architecture (data/domain/presentation), Ant Design component library

### Cây thư mục React (rút gọn)
```
react-staff-admin/
├── src/
│   ├── App.tsx                          # Root component, BrowserRouter
│   ├── index.tsx                        # ReactDOM.render + QueryClientProvider
│   ├── core/
│   │   ├── components/
│   │   │   └── main_layout.tsx          # Sidebar + TopBar layout wrapper
│   │   ├── di/                          # Dependency config
│   │   ├── firebase/                    # Firebase config cho React
│   │   ├── network/                     # Axios instance, interceptors
│   │   ├── routes/
│   │   │   └── app_routes.tsx           # PrivateGuard, PublicGuard, all routes
│   │   ├── theme/                       # Ant Design theme config
│   │   └── utils/
│   │       └── auth_storage.ts          # JWT storage, UserSession type
│   └── features/
│       ├── auth/presentation/pages/
│       │   ├── login_page.tsx           # Đăng nhập STAFF/ADMIN
│       │   └── profile_page.tsx         # Trang hồ sơ cá nhân
│       ├── booking/presentation/pages/
│       │   ├── admin_supervision_page.tsx  # Admin xem tổng quan booking
│       │   ├── booking_detail_page.tsx     # Chi tiết booking (dùng cho cả admin/staff)
│       │   ├── staff_bookings_page.tsx     # Staff quản lý booking
│       │   └── staff_overview_page.tsx     # Staff dashboard overview
│       ├── facility/presentation/pages/
│       │   ├── admin_facilities_page.tsx   # Admin quản lý cơ sở
│       │   ├── admin_courts_page.tsx       # Admin quản lý sân
│       │   ├── admin_sports_page.tsx       # Admin quản lý môn thể thao
│       │   ├── staff_courts_page.tsx       # Staff xem sân
│       │   ├── staff_slots_page.tsx        # Staff cấu hình slot
│       │   └── staff_sports_page.tsx       # Staff xem môn thể thao
│       ├── fixed_schedule/presentation/pages/
│       │   ├── fixed_schedule_list_page.tsx   # Danh sách lịch cố định
│       │   └── fixed_schedule_detail_page.tsx # Chi tiết + approve/reject
│       ├── matching/presentation/pages/
│       │   ├── matching_list_page.tsx      # Danh sách matching sessions
│       │   └── matching_detail_page.tsx    # Chi tiết session
│       ├── payment/presentation/pages/
│       │   └── staff_cashier_page.tsx      # Thu tiền mặt
│       ├── report/presentation/pages/
│       │   ├── admin_overview_page.tsx     # Dashboard tổng hợp cho ADMIN
│       │   └── staff_report_page.tsx       # Báo cáo cho STAFF
│       ├── notification/presentation/
│       │   ├── pages/
│       │   │   ├── admin_notifications_page.tsx
│       │   │   └── staff_notifications_page.tsx
│       │   └── components/
│       ├── review/presentation/pages/
│       │   ├── review_list_page.tsx        # Danh sách đánh giá
│       │   └── review_detail_page.tsx
│       └── user_management/presentation/pages/
│           └── admin_users_page.tsx        # Admin quản lý người dùng
└── package.json
```

### Route map React Web Admin

| Route URL | Component | Role | Mô tả |
|-----------|-----------|------|-------|
| `/sign-in` | `login_page.tsx` | Public | Đăng nhập |
| `/admin/overview` | `admin_overview_page.tsx` | ADMIN | Dashboard tổng quan |
| `/admin/facilities` | `admin_facilities_page.tsx` | ADMIN | Quản lý cơ sở |
| `/admin/courts` | `admin_courts_page.tsx` | ADMIN | Quản lý sân |
| `/admin/sports` | `admin_sports_page.tsx` | ADMIN | Quản lý môn thể thao |
| `/admin/users` | `admin_users_page.tsx` | ADMIN | Quản lý người dùng |
| `/admin/supervision` | `admin_supervision_page.tsx` | ADMIN | Giám sát booking |
| `/admin/bookings/:id` | `booking_detail_page.tsx` | ADMIN | Chi tiết booking |
| `/admin/fixed-schedules` | `fixed_schedule_list_page.tsx` | ADMIN | Lịch cố định |
| `/admin/fixed-schedules/:id` | `fixed_schedule_detail_page.tsx` | ADMIN | Chi tiết lịch cố định |
| `/admin/matching` | `matching_list_page.tsx` | ADMIN | Danh sách ghép trận |
| `/admin/matching/:id` | `matching_detail_page.tsx` | ADMIN | Chi tiết ghép trận |
| `/admin/reviews` | `review_list_page.tsx` | ADMIN | Đánh giá |
| `/admin/reviews/:id` | `review_detail_page.tsx` | ADMIN | Chi tiết đánh giá |
| `/admin/notifications` | `admin_notifications_page.tsx` | ADMIN | Thông báo |
| `/admin/profile` | `profile_page.tsx` | ADMIN | Hồ sơ |
| `/staff/overview` | `staff_overview_page.tsx` | STAFF | Dashboard STAFF |
| `/staff/bookings` | `staff_bookings_page.tsx` | STAFF | Quản lý booking |
| `/staff/bookings/:id` | `booking_detail_page.tsx` | STAFF | Chi tiết booking |
| `/staff/fixed-schedules` | `fixed_schedule_list_page.tsx` | STAFF | Lịch cố định |
| `/staff/fixed-schedules/:id` | `fixed_schedule_detail_page.tsx` | STAFF | Chi tiết lịch cố định |
| `/staff/matching` | `matching_list_page.tsx` | STAFF | Ghép trận |
| `/staff/matching/:id` | `matching_detail_page.tsx` | STAFF | Chi tiết ghép trận |
| `/staff/reviews` | `review_list_page.tsx` | STAFF | Đánh giá |
| `/staff/cashier` | `staff_cashier_page.tsx` | STAFF | Thu tiền mặt |
| `/staff/operations/slots` | `staff_slots_page.tsx` | STAFF | Cấu hình slot |
| `/staff/operations/courts` | `staff_courts_page.tsx` | STAFF | Quản lý sân |
| `/staff/operations/sports` | `staff_sports_page.tsx` | STAFF | Môn thể thao |
| `/staff/report` | `staff_report_page.tsx` | STAFF | Báo cáo |
| `/staff/notifications` | `staff_notifications_page.tsx` | STAFF | Thông báo |
| `/staff/profile` | `profile_page.tsx` | STAFF | Hồ sơ |
