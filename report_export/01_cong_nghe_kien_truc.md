# 2. CÔNG NGHỆ VÀ KIẾN TRÚC

## 2.1 Công nghệ sử dụng

### Flutter / Dart
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Framework phát triển ứng dụng di động Android cho CUSTOMER |
| **Phiên bản SDK** | Dart SDK `^3.12.0` |
| **File chứng minh** | `sports_management/pubspec.yaml` |
| **Ưu điểm** | Hot reload, UI đẹp, cross-platform, BLoC pattern rõ ràng |
| **Hạn chế** | Chỉ deploy Android, chưa test iOS |

**Thư viện Flutter chính:**
| Thư viện | Phiên bản | Mục đích |
|----------|-----------|---------|
| `flutter_bloc` | ^8.1.6 | State management (BLoC/Cubit pattern) |
| `go_router` | ^14.2.0 | Navigation/Routing |
| `get_it` | ^8.0.2 | Dependency Injection |
| `dio` | ^5.7.0 | HTTP Client gọi API |
| `socket_io_client` | ^2.0.3 | Kết nối WebSocket real-time |
| `firebase_messaging` | ^15.1.3 | Push notification FCM |
| `firebase_auth` | ^5.3.1 | Firebase Auth |
| `flutter_local_notifications` | ^18.0.1 | Hiển thị thông báo local |
| `flutter_secure_storage` | ^9.2.2 | Lưu trữ token bảo mật |
| `shared_preferences` | ^2.3.0 | Lưu trữ cài đặt |
| `cached_network_image` | ^3.4.1 | Cache hình ảnh từ URL |
| `dartz` | ^0.10.1 | Functional programming (Either) |
| `equatable` | ^2.0.5 | So sánh object |
| `freezed` | ^2.5.7 | Code generation (immutable models) |
| `json_serializable` | ^6.9.0 | JSON serialization |
| `intl` | ^0.19.0 | Định dạng ngày giờ, số |
| `image_picker` | ^1.1.2 | Chọn ảnh từ thư viện/camera |
| `url_launcher` | ^6.3.0 | Mở URL/deeplink |

---

### React / TypeScript
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Framework phát triển Web Admin cho ADMIN và STAFF |
| **Framework** | Create React App (react-scripts 5.0.1) |
| **File chứng minh** | `react-staff-admin/package.json` |
| **Ưu điểm** | Phân chia feature rõ ràng, phân quyền route, TypeScript type-safe |
| **Hạn chế** | CRA không tối ưu production build bằng Vite |

**Thư viện React chính:**
| Thư viện | Phiên bản | Mục đích |
|----------|-----------|---------|
| `antd` | ^6.4.3 | UI Component Library (Ant Design) |
| `@ant-design/icons` | ^6.2.3 | Icon library |
| `react-router-dom` | ^7.15.1 | Client-side routing |
| `@tanstack/react-query` | ^5.100.14 | Server state management, caching |
| `axios` | ^1.16.1 | HTTP Client gọi API |
| `recharts` | ^3.8.1 | Biểu đồ báo cáo |
| `socket.io-client` | ^4.7.5 | Real-time notifications |
| `tailwindcss` | ^3.4.17 | Utility CSS |
| `lucide-react` | ^1.16.0 | Icon library bổ sung |
| `typescript` | ^4.9.5 | Type safety |

---

### Node.js / Express.js
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | REST API Backend, WebSocket Server, Cron Job Runner |
| **Phiên bản** | Node.js (CommonJS modules) |
| **Entry point** | `node_be_refactor/src/main.js` |
| **Ưu điểm** | Non-blocking I/O, dễ mở rộng, hệ sinh thái npm phong phú |
| **Hạn chế** | Single-threaded, cron job phụ thuộc vào server không ngủ |

**Thư viện Node.js chính:**
| Thư viện | Phiên bản | Mục đích |
|----------|-----------|---------|
| `express` | ^4.19.2 | Web framework, routing, middleware |
| `mongoose` | ^8.24.0 | ODM cho MongoDB |
| `jsonwebtoken` | ^9.0.3 | Tạo/xác thực JWT |
| `bcrypt` | ^6.0.0 | Mã hóa mật khẩu |
| `cors` | ^2.8.5 | Cross-Origin Resource Sharing |
| `dotenv` | ^16.4.5 | Quản lý biến môi trường |
| `socket.io` | ^4.7.2 | WebSocket real-time |
| `firebase-admin` | ^13.10.0 | Push notification (FCM), Firebase Admin |
| `node-cron` | ^4.2.1 | Cron job scheduler |
| `cloudinary` | ^1.41.3 | Upload và quản lý media |
| `multer` | ^2.1.1 | Xử lý file upload (multipart/form-data) |
| `multer-storage-cloudinary` | ^4.0.0 | Storage adapter cho Cloudinary |
| `nodemailer` | ^8.0.10 | Gửi email OTP đặt lại mật khẩu |
| `nodemon` | ^3.1.0 | Auto-restart server khi dev |

---

### MongoDB / Mongoose
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Cơ sở dữ liệu NoSQL chính |
| **ODM** | Mongoose v8.24.0 |
| **File chứng minh** | `src/config/mongo.js`, tất cả file `*.model.js` |
| **Ưu điểm** | Schema linh hoạt, embed document, dễ mở rộng |
| **Hạn chế** | Không hỗ trợ transaction phức tạp như SQL, cần quản lý index thủ công |

---

### Firebase Admin / FCM
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Push notification đến thiết bị di động, Firebase Auth |
| **File chứng minh** | `firebase-admin` trong `package.json`, `firebase_options.dart`, `firebase_messaging` trong Flutter |
| **Cấu hình** | `src/config/serviceAccountKey.json.template` (cần file thật để hoạt động) |
| **Ưu điểm** | Push notification kể cả khi app đóng, xác thực qua Firebase |
| **Hạn chế** | Cần file `serviceAccountKey.json` thật mới push được; hiện có template |

---

### Socket.IO
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Real-time notification cho người dùng đang online |
| **File Backend** | `src/services/socket-io.service.js` |
| **File Flutter** | `socket_io_client: ^2.0.3` trong pubspec.yaml |
| **Events** | `notification_received`, `new_notification`, `matching_session_updated`, `join_matching_room`, `ping/pong` |
| **Ưu điểm** | Thông báo tức thì, hỗ trợ rooms (per-user, room_staff, room_admin, room_matching) |
| **Hạn chế** | Socket kết nối phụ thuộc vào server không ngủ (vấn đề với Render Free Tier) |

---

### ZaloPay
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Cổng thanh toán điện tử |
| **File Backend** | `src/services/zalopay.service.js`, `src/controllers/zalopay.controller.js` |
| **Endpoints** | `POST /api/v1/zalopay/create-order`, `POST /api/v1/zalopay/callback`, `POST /api/v1/zalopay/query` |
| **Ưu điểm** | Thanh toán thật, webhook callback, xác thực HMAC |
| **Hạn chế** | Cần môi trường sandbox/production để test đầy đủ |

---

### node-cron / Cron Jobs
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Tự động hóa tác vụ nền |
| **File chứng minh** | `src/utils/cron-*.js` |
| **Cron đang chạy** | 4 cron jobs (matchmaker, fixed-scheduler, auto-cancel, auto-complete) |
| **Rủi ro** | Render Free Tier sleep sau 15 phút không có request → cron bị dừng |

---

### Cloudinary
| Thuộc tính | Chi tiết |
|------------|----------|
| **Vai trò** | Lưu trữ và quản lý ảnh (avatar, ảnh sân) |
| **File chứng minh** | `src/services/upload.service.js`, `src/middlewares/upload.middleware.js` |
| **Endpoint** | `POST /api/v1/upload` |

---

## 2.2 Kiến trúc tổng thể

Hệ thống được xây dựng theo mô hình **Client-Server đa tầng**, với Backend đóng vai trò trung tâm phục vụ nhiều loại client:

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                            │
│                                                             │
│  ┌─────────────────────┐   ┌─────────────────────────────┐ │
│  │   Flutter Android   │   │   React Web Admin (SPA)     │ │
│  │   (CUSTOMER App)    │   │   (ADMIN + STAFF Portal)    │ │
│  └──────────┬──────────┘   └──────────────┬──────────────┘ │
│             │                             │                 │
└─────────────┼─────────────────────────────┼─────────────────┘
              │  HTTP REST API              │  HTTP REST API
              │  WebSocket (Socket.IO)      │  WebSocket (Socket.IO)
              │                             │
┌─────────────▼─────────────────────────────▼─────────────────┐
│                     BACKEND LAYER                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Node.js / Express.js Server               │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │   │
│  │  │  REST API   │  │  Socket.IO  │  │ Cron Jobs  │  │   │
│  │  │  /api/v1/*  │  │  Real-time  │  │  (4 jobs)  │  │   │
│  │  └─────────────┘  └─────────────┘  └────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────────┐
        │              │                  │
┌───────▼──────┐ ┌─────▼──────┐ ┌────────▼───────┐
│   MongoDB    │ │  Firebase  │ │   Cloudinary   │
│  (Database)  │ │   (FCM)    │ │ (Media Storage)│
└──────────────┘ └────────────┘ └────────────────┘
```

**Mô tả luồng chính:**
1. **Flutter App** gửi HTTP request đến Backend API và kết nối WebSocket để nhận thông báo real-time
2. **React Web Admin** gửi HTTP request đến Backend API; STAFF/ADMIN nhận thông báo qua Socket.IO rooms `room_staff`, `room_admin`
3. **Backend** xử lý nghiệp vụ, lưu dữ liệu vào MongoDB, gửi push notification qua Firebase FCM cho thiết bị offline
4. **Cron Jobs** chạy tự động để sinh lịch cố định, ghép trận, hủy booking quá hạn
5. **ZaloPay** tích hợp webhook callback để cập nhật trạng thái payment

---

## 2.3 Kiến trúc Backend

Backend được tổ chức theo mô hình **Layered Architecture** (tầng hóa):

```
node_be_refactor/src/
├── main.js                         # Entry point: khởi tạo Express, Socket.IO, Cron
├── config/
│   ├── mongo.js                    # Kết nối MongoDB
│   └── serviceAccountKey.json.template  # Cấu hình Firebase (template)
├── routes/
│   ├── index.js                    # Router tổng hợp, API tracker UI
│   ├── auth.routes.js              # /api/v1/auth/*
│   ├── user.routes.js              # /api/v1/user/*
│   ├── facility.routes.js          # /api/v1/facility/*
│   ├── sport.routes.js             # /api/v1/sport/*
│   ├── court.routes.js             # /api/v1/court/*
│   ├── court-blocks.routes.js      # /api/v1/court-blocks/*
│   ├── booking.routes.js           # /api/v1/booking/*
│   ├── payment.routes.js           # /api/v1/payment/*
│   ├── fixed-schedule.routes.js    # /api/v1/fixed-schedule/*
│   ├── matching.routes.js          # /api/v1/matching/*
│   ├── notification.routes.js      # /api/v1/notification/*
│   ├── reports.routes.js           # /api/v1/reports/*
│   ├── review.routes.js            # /api/v1/review/*
│   ├── upload.routes.js            # /api/v1/upload/*
│   └── zalopay.routes.js           # /api/v1/zalopay/*
├── controllers/                    # Nhận request, trả response, gọi service
│   ├── auth.controller.js
│   ├── booking.controller.js
│   ├── court-blocks.controller.js
│   ├── court.controller.js
│   ├── facility.controller.js
│   ├── fcm.controller.js
│   ├── fixed-schedule.controller.js
│   ├── matching.controller.js
│   ├── notification.controller.js
│   ├── payment.controller.js
│   ├── reports.controller.js
│   ├── review.controller.js
│   ├── sport.controller.js
│   ├── upload.controller.js
│   ├── user.controller.js
│   └── zalopay.controller.js
├── services/                       # Business logic
│   ├── booking.service.js          # (~34KB) Xử lý booking, conflict check
│   ├── fixed-schedule.service.js   # (~78KB) Sinh booking từ lịch cố định
│   ├── matching.service.js         # (~70KB) Thuật toán ghép trận
│   ├── payment.service.js          # (~20KB) Xử lý payment
│   ├── report.service.js           # (~41KB) Tổng hợp báo cáo
│   ├── notification.helper.js      # (~16KB) Helper gửi thông báo
│   ├── socket-io.service.js        # WebSocket service
│   ├── fcm.service.js              # Firebase Cloud Messaging
│   ├── zalopay.service.js          # ZaloPay integration
│   ├── court-availability.service.js # Kiểm tra slot sân còn trống
│   ├── court-block.service.js      # Quản lý khóa sân
│   ├── court.service.js            # CRUD sân
│   ├── facility.service.js         # CRUD cơ sở
│   ├── sport.service.js            # CRUD môn thể thao
│   ├── user-auth.service.js        # Auth logic (login, register, OTP)
│   ├── user.service.js             # User profile
│   ├── mail.service.js             # Gửi email OTP
│   ├── review.service.js           # Đánh giá
│   ├── upload.service.js           # Upload Cloudinary
│   ├── user-schedule-conflict.service.js  # Kiểm tra xung đột lịch của user
│   └── booking-price.service.js    # Tính giá booking
├── repositories/
│   └── fixed-schedule.repository.js  # Query phức tạp cho fixed schedule
├── models/                         # MongoDB Schema (Mongoose)
│   ├── user.model.js
│   ├── facility.model.js
│   ├── sport.model.js
│   ├── court.model.js              # Bao gồm courtSlotSchema, slotConfigSchema
│   ├── court-block.model.js
│   ├── booking.model.js
│   ├── payment.model.js
│   ├── fixed-schedule.model.js
│   ├── matching.model.js           # Bao gồm matchingMemberSchema, matchingTeamSchema
│   ├── match-queue.model.js
│   ├── notification.model.js
│   └── review.model.js
├── middlewares/
│   ├── auth.middleware.js          # verifyToken, requireRole
│   └── upload.middleware.js        # Multer + Cloudinary storage
└── utils/
    ├── cron-matchmaker.js          # Cron: */1 phút – ghép trận tự động
    ├── cron-fixed-scheduler.js     # Cron: 00:05 hàng ngày – sinh booking cố định
    ├── cron-auto-cancel-bookings.js # Cron: */1 phút – hủy booking quá hạn
    ├── cron-auto-complete-bookings.js # Cron: tự động hoàn thành booking
    ├── booking-time.util.js        # Utility tính toán thời gian slot
    └── response.util.js            # Chuẩn hóa response format
```

---

## 2.4 Kiến trúc Flutter

Flutter được tổ chức theo mô hình **Feature-First Module Architecture** kết hợp **Clean Architecture (Domain/Data/Presentation)**:

```
sports_management/
├── lib/
│   ├── main.dart                   # Entry point, khởi tạo Firebase, DI
│   ├── app.dart                    # MaterialApp, theme
│   ├── firebase_options.dart       # Cấu hình Firebase
│   ├── core/                       # Core utilities dùng chung
│   ├── injection/                  # Dependency Injection (get_it)
│   └── router/
│       ├── app_router.dart         # GoRouter configuration
│       └── route_paths.dart        # Tất cả route paths constants
└── modules/
    ├── app_module/                 # Module khởi động app
    ├── server_module/              # API client (Dio), base network
    ├── authentication_module/
    │   └── lib/
    │       ├── data/               # Repository impl, API datasource
    │       ├── domain/             # Entity, UseCase, Repository interface
    │       ├── presentation/
    │       │   ├── pages/          # SignInPage, SignUpPage, ResetPasswordPage
    │       │   └── cubit/ (or bloc/)
    │       └── application/        # DI
    ├── home_module/
    │   └── lib/presentation/       # HomePage (main tab)
    ├── booking_module/
    │   └── lib/
    │       ├── data/
    │       ├── domain/
    │       └── presentation/
    │           └── pages/
    │               ├── court_booking_page.dart        # (~65KB) Màn hình đặt sân
    │               ├── booking_history_page.dart      # (~22KB) Lịch sử đặt sân
    │               ├── booking_detail_page.dart       # (~26KB) Chi tiết booking
    │               └── booking_catalog_full_page.dart # Danh mục sân
    ├── matching_module/
    │   └── lib/
    │       ├── data/
    │       ├── domain/
    │       ├── di/
    │       └── presentation/
    │           └── pages/
    │               ├── create_matching_session_page.dart  # (~85KB) Tạo phiên ghép trận
    │               ├── matching_explorer_page.dart        # (~37KB) Tìm kiếm phiên ghép trận
    │               ├── matching_detail_page.dart          # (~38KB) Chi tiết phiên ghép trận
    │               └── auto_matching_lobby_page.dart      # (~30KB) Lobby ghép tự động
    ├── payment_module/
    │   └── lib/presentation/       # Màn hình hóa đơn, thanh toán ZaloPay
    ├── notification_module/
    │   └── lib/
    │       ├── core/               # FCM setup, local notification handler
    │       └── presentation/       # Danh sách thông báo
    ├── facility_module/
    │   └── lib/presentation/       # Danh sách cơ sở, chi tiết sân
    ├── user_management_module/
    │   └── lib/presentation/       # Hồ sơ người dùng
    └── review_module/
        └── lib/presentation/       # Đánh giá dịch vụ
```

**State Management:** BLoC/Cubit pattern (`flutter_bloc`)
- Mỗi module có Cubit/BLoC riêng quản lý state
- State sử dụng `equatable` để so sánh

**Dependency Injection:** `get_it` (Service Locator)
- Mỗi module có thư mục `di/` hoặc `application/` đăng ký dependencies

**Navigation:** `go_router`
- Tất cả route paths được định nghĩa tập trung trong `route_paths.dart`

---

## 2.5 Kiến trúc React Web Admin

React Web Admin được tổ chức theo mô hình **Feature-Based Architecture** kết hợp **Clean Architecture**:

```
react-staff-admin/src/
├── App.tsx                         # Root component
├── index.tsx                       # React entry point
├── core/
│   ├── components/
│   │   └── main_layout.tsx         # Layout chính (Sidebar + Header)
│   ├── di/                         # Dependency Injection
│   ├── network/                    # Axios instance, interceptors
│   ├── routes/
│   │   └── app_routes.tsx          # Định nghĩa tất cả routes + PrivateGuard
│   ├── theme/                      # Ant Design theme config
│   └── utils/
│       └── auth_storage.ts         # LocalStorage auth utilities
└── features/
    ├── auth/
    │   └── presentation/pages/
    │       ├── login_page.tsx       # Trang đăng nhập
    │       └── profile_page.tsx     # Trang hồ sơ
    ├── booking/
    │   └── presentation/pages/
    │       ├── admin_supervision_page.tsx  # ADMIN: Giám sát booking
    │       ├── staff_bookings_page.tsx     # STAFF: Danh sách booking
    │       ├── staff_overview_page.tsx     # STAFF: Tổng quan ngày
    │       └── booking_detail_page.tsx     # Chi tiết booking (Admin+Staff)
    ├── facility/
    │   └── presentation/pages/
    │       ├── admin_facilities_page.tsx   # Quản lý cơ sở
    │       ├── admin_courts_page.tsx       # Quản lý sân (Admin)
    │       ├── admin_sports_page.tsx       # Quản lý môn thể thao (Admin)
    │       ├── staff_courts_page.tsx       # Quản lý sân (Staff)
    │       ├── staff_sports_page.tsx       # Quản lý môn thể thao (Staff)
    │       └── staff_slots_page.tsx        # Quản lý slot giờ
    ├── payment/
    │   └── presentation/pages/
    │       └── staff_cashier_page.tsx      # Thu ngân
    ├── fixed_schedule/
    │   └── presentation/pages/
    │       ├── fixed_schedule_list_page.tsx    # Danh sách lịch cố định
    │       └── fixed_schedule_detail_page.tsx  # Chi tiết lịch cố định
    ├── matching/
    │   └── presentation/pages/
    │       ├── matching_list_page.tsx      # Danh sách phiên ghép trận
    │       └── matching_detail_page.tsx    # Chi tiết phiên ghép trận
    ├── report/
    │   └── presentation/pages/
    │       ├── admin_overview_page.tsx     # Dashboard báo cáo Admin
    │       └── staff_report_page.tsx       # Báo cáo Staff
    ├── notification/
    │   └── presentation/pages/
    │       ├── admin_notifications_page.tsx
    │       └── staff_notifications_page.tsx
    ├── user_management/
    │   └── presentation/pages/
    │       └── admin_users_page.tsx        # Quản lý người dùng
    └── review/
        └── presentation/pages/
            ├── review_list_page.tsx        # Danh sách đánh giá
            └── review_detail_page.tsx      # Chi tiết đánh giá
```

**Route Guard:**
- `PrivateGuard`: Kiểm tra JWT + role, redirect về `/sign-in` nếu chưa đăng nhập
- `PublicGuard`: Redirect về dashboard nếu đã đăng nhập
- Phân quyền theo role: ADMIN/STAFF có menu và trang khác nhau

**Server State:** `@tanstack/react-query` – cache và refetch dữ liệu tự động

**UI Framework:** Ant Design 6 + TailwindCSS hybrid
