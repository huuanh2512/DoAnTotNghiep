# 12. NỘI DUNG VIẾT SẴN CHO BÁO CÁO

> **Hướng dẫn sử dụng**: Các đoạn văn dưới đây được viết theo phong cách học thuật, chuyên nghiệp bằng tiếng Việt. Có thể copy trực tiếp vào báo cáo và chỉnh sửa để phù hợp với format của trường.

---

## PHẦN 1: GIỚI THIỆU ĐỀ TÀI

### 1.1 Lý do chọn đề tài

Trong bối cảnh xã hội hiện đại ngày càng chú trọng đến sức khỏe và lối sống năng động, nhu cầu tham gia các hoạt động thể dục thể thao tại các khu liên hợp thể thao ngày càng tăng cao. Tuy nhiên, hầu hết các khu liên hợp thể thao tại Việt Nam hiện nay vẫn còn áp dụng phương thức quản lý thủ công: đặt sân qua điện thoại, ghi chép lịch bằng sổ tay, thu tiền mặt không có hóa đơn điện tử, và thiếu hoàn toàn các công cụ báo cáo thống kê. Điều này dẫn đến nhiều bất cập như: nhầm lịch đặt sân, khó quản lý doanh thu, thiếu minh bạch trong thanh toán, và không có kênh kết nối giữa những người chơi có cùng nhu cầu tìm đối thủ.

Bên cạnh đó, sự phát triển vượt bậc của nền tảng di động và hệ sinh thái công nghệ đám mây đã tạo ra cơ hội để xây dựng các giải pháp số hóa toàn diện, đáp ứng kịp thời nhu cầu quản lý và kết nối cộng đồng thể thao. Đặc biệt, tính năng "tìm kiếm đối thủ" — cho phép người chơi tự ghép cặp hoặc tìm đội đấu theo thời gian và địa điểm phù hợp — là một điểm khác biệt hoàn toàn chưa được khai thác bởi các ứng dụng thể thao hiện có tại thị trường nội địa.

Chính từ những quan sát thực tế đó, nhóm tác giả quyết định lựa chọn đề tài "**Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ trên nền tảng Android và Web quản trị**" nhằm giải quyết các bài toán trên một cách toàn diện.

---

### 1.2 Mục tiêu đề tài

Đề tài hướng đến xây dựng một hệ thống thông tin hoàn chỉnh, bao gồm ba thành phần chính:

**Thứ nhất**, ứng dụng di động Android (xây dựng bằng Flutter) phục vụ khách hàng (CUSTOMER) với các chức năng: xem thông tin cơ sở thể thao, đặt sân theo slot thời gian, tạo và quản lý lịch đặt sân cố định định kỳ, tìm kiếm đối thủ (ghép trận thủ công hoặc tự động), thanh toán trực tuyến qua ZaloPay, nhận thông báo theo thời gian thực, và đánh giá trải nghiệm sau khi sử dụng.

**Thứ hai**, ứng dụng web quản trị (xây dựng bằng React + TypeScript) phục vụ nhân viên (STAFF) và quản trị viên (ADMIN) với các chức năng: quản lý cơ sở, sân, môn thể thao; duyệt và quản lý booking; thu tiền; báo cáo hiệu suất và doanh thu; và giám sát toàn bộ hệ thống.

**Thứ ba**, hệ thống backend (Node.js/Express/MongoDB) đảm nhận toàn bộ business logic, xử lý API, quản lý dữ liệu, tích hợp cổng thanh toán ZaloPay, gửi thông báo qua Socket.IO và Firebase FCM, và tự động hóa các tác vụ định kỳ qua cron jobs.

---

### 1.3 Phạm vi và giới hạn

**Phạm vi hệ thống**:
- Quản lý tối đa N cơ sở thể thao, mỗi cơ sở có nhiều sân và nhiều loại môn thể thao
- Phục vụ 3 nhóm người dùng: CUSTOMER (khách hàng), STAFF (nhân viên), ADMIN (quản trị viên)
- Hỗ trợ đặt sân theo slot (tối thiểu 30 phút), lịch cố định (DAILY/WEEKLY), và ghép trận
- Tích hợp thanh toán ZaloPay (Sandbox cho mục đích demo)

**Giới hạn**:
- Chưa tích hợp thanh toán VNPay, MoMo trong phiên bản hiện tại
- Tính năng hoàn tiền tự động chưa được triển khai hoàn toàn
- Ứng dụng iOS về mặt kỹ thuật có thể build được nhưng chưa được publish lên App Store
- Hệ thống không có tính năng chat/messaging giữa người dùng

---

## PHẦN 2: CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ

### 2.1 Các công nghệ sử dụng

#### Node.js và Express.js

Node.js là nền tảng runtime JavaScript phía server, được xây dựng trên V8 engine của Google Chrome. Với mô hình xử lý bất đồng bộ (non-blocking I/O) và kiến trúc hướng sự kiện (event-driven), Node.js cho phép xử lý hàng nghìn kết nối đồng thời với tài nguyên hệ thống tối thiểu, phù hợp với các ứng dụng thời gian thực.

Express.js là framework web tối giản và linh hoạt cho Node.js, cung cấp các tính năng cơ bản để xây dựng RESTful API như routing, middleware chaining, error handling. Sự kết hợp Node.js + Express.js là một trong những lựa chọn phổ biến nhất cho backend API hiện đại.

Trong đề tài này, toàn bộ backend được xây dựng trên Express.js với kiến trúc phân lớp rõ ràng: Controller (tiếp nhận request) → Service (xử lý nghiệp vụ) → Repository (truy vấn dữ liệu) → Model (định nghĩa schema).

#### MongoDB và Mongoose

MongoDB là hệ quản trị cơ sở dữ liệu NoSQL hướng document, lưu trữ dữ liệu dưới dạng BSON (Binary JSON). Ưu điểm của MongoDB trong hệ thống này là khả năng lưu trữ các document phức tạp có cấu trúc lồng nhau (như `slot_config` trong Court, `members[]` trong MatchingSession, `exception_dates[]` trong FixedSchedule) mà không cần nhiều bảng join như cơ sở dữ liệu quan hệ.

Mongoose là ODM (Object Document Mapper) cung cấp schema validation, middleware hooks, và query builder hướng đối tượng cho MongoDB trên Node.js. Mongoose được sử dụng để định nghĩa tất cả 12 schema trong hệ thống và thực hiện toàn bộ truy vấn dữ liệu.

#### Flutter và Dart

Flutter là framework UI đa nền tảng của Google cho phép xây dựng ứng dụng native cho Android, iOS, Web và Desktop từ một codebase duy nhất sử dụng ngôn ngữ Dart. Flutter sử dụng Skia/Impeller rendering engine để vẽ trực tiếp các widget lên canvas, đảm bảo giao diện nhất quán trên mọi thiết bị.

Trong đề tài, Flutter được sử dụng để xây dựng ứng dụng Android phục vụ khách hàng. Kiến trúc được áp dụng là Clean Architecture kết hợp BLoC/Cubit pattern để quản lý state, đảm bảo tách biệt hoàn toàn giữa lớp giao diện (Presentation), lớp nghiệp vụ (Domain), và lớp dữ liệu (Data). Dependency injection được quản lý bởi thư viện `get_it`.

#### React và TypeScript

React là thư viện JavaScript của Facebook để xây dựng giao diện người dùng dựa trên component. TypeScript là ngôn ngữ typed superset của JavaScript, giúp phát hiện lỗi tại compile-time thay vì runtime, cải thiện đáng kể trải nghiệm phát triển và chất lượng code.

Web Admin trong đề tài được xây dựng bằng React + TypeScript kết hợp Ant Design (UI component library), TanStack React Query (quản lý server state và caching), React Router DOM v7 (routing), và Recharts (biểu đồ báo cáo).

#### Socket.IO

Socket.IO là thư viện cung cấp giao tiếp hai chiều thời gian thực giữa client và server thông qua WebSocket (với fallback về long-polling nếu WebSocket không khả dụng). Trong hệ thống, Socket.IO được tích hợp vào backend Node.js để phát thông báo tức thời đến Flutter app và React web khi có sự kiện quan trọng (booking được xác nhận, ghép trận thành công, payment hoàn tất...).

#### Firebase và FCM

Firebase là nền tảng Backend-as-a-Service của Google cung cấp nhiều dịch vụ cho mobile app. Trong đề tài này, hai dịch vụ được sử dụng: Firebase Authentication (đăng nhập Google qua Firebase) và Firebase Cloud Messaging (FCM — gửi push notification đến thiết bị Android ngay cả khi app đang ở background hoặc đã tắt).

#### ZaloPay

ZaloPay là cổng thanh toán điện tử phổ biến tại Việt Nam. Hệ thống tích hợp ZaloPay API để cho phép khách hàng thanh toán trực tuyến ngay trong ứng dụng thông qua WebView tích hợp. Kết quả giao dịch được ZaloPay thông báo về backend qua callback URL sử dụng HMAC-SHA256 để đảm bảo tính xác thực.

#### JWT (JSON Web Token)

JWT là chuẩn mở (RFC 7519) để truyền thông tin xác thực giữa các parties dưới dạng JSON object được ký số. Hệ thống sử dụng JWT để xác thực người dùng: Access Token (ngắn hạn) cho mỗi request API, Refresh Token (dài hạn) để lấy Access Token mới khi hết hạn.

---

### 2.2 Kiến trúc RESTful API

API của hệ thống tuân theo các nguyên tắc REST (Representational State Transfer):
- **Stateless**: Mỗi request chứa đầy đủ thông tin xác thực (Bearer Token), server không lưu session state
- **Resource-based URL**: `/api/v1/booking`, `/api/v1/court/:id/slot-config`
- **HTTP Methods**: GET (lấy dữ liệu), POST (tạo mới), PUT (cập nhật), DELETE (xóa)
- **Consistent Response Format**: Tất cả response tuân theo format `{ success, data, message }`

---

### 2.3 BLoC Pattern trong Flutter

BLoC (Business Logic Component) là pattern quản lý state trong Flutter, tách biệt hoàn toàn business logic khỏi UI. Trong mô hình này:
- **Bloc/Cubit**: Nhận Events từ UI, xử lý business logic, emit States
- **State**: Các trạng thái của màn hình (Loading, Success, Error, Initial)
- **Event**: Các hành động từ người dùng hoặc hệ thống kích hoạt thay đổi state

Ví dụ trong hệ thống: `BookingCubit` quản lý state của màn hình đặt sân, emit các state như `BookingLoadingState`, `BookingSuccessState`, `BookingErrorState`.

---

## PHẦN 3: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG

### 3.1 Mô tả bài toán

Bài toán đặt ra là số hóa toàn bộ quy trình vận hành một khu liên hợp thể thao, từ phía khách hàng đến phía quản lý. Hệ thống cần giải quyết các vấn đề sau:

**Về phía khách hàng**:
- Xem danh sách cơ sở, sân, môn thể thao và đặt sân trực tiếp qua điện thoại
- Quản lý lịch đặt sân định kỳ (hàng tuần, hàng ngày) mà không cần đặt lại từng lần
- Tìm kiếm đối thủ thi đấu cùng thời gian và địa điểm
- Thanh toán trực tuyến và theo dõi hóa đơn

**Về phía quản lý (STAFF/ADMIN)**:
- Quản lý đặt sân, duyệt/từ chối, thu tiền tại quầy
- Cấu hình cơ sở, sân, slot thời gian, giá thuê
- Xem báo cáo doanh thu và hiệu suất theo cơ sở, theo thời gian
- Quản lý người dùng và phân quyền

**Các ràng buộc nghiệp vụ**:
- Không cho phép đặt trùng lịch sân
- Booking không thanh toán sau một khoảng thời gian nhất định sẽ tự động bị hủy
- Lịch cố định cần được nhân viên duyệt trước khi có hiệu lực
- Ghép trận tự động dựa trên tiêu chí: môn thể thao, cơ sở, ngày, giờ

---

### 3.2 Đặc tả chức năng hệ thống — Tóm tắt

**Quản lý tài khoản (UC01-UC06)**:
Hệ thống hỗ trợ đăng ký tài khoản bằng email với xác thực OTP, đăng nhập qua email/mật khẩu hoặc Google (Firebase Authentication), và cơ chế quên/đặt lại mật khẩu qua OTP email. Phân quyền được thực hiện theo 3 cấp: CUSTOMER, STAFF, ADMIN.

**Đặt sân trực tuyến (UC04-UC06)**:
Khách hàng có thể xem danh sách sân theo cơ sở và môn thể thao, kiểm tra lịch trống theo từng ngày, và đặt sân theo slot thời gian (tối thiểu 30 phút). Hệ thống tự động kiểm tra xung đột lịch và tính giá tiền. Sau khi đặt, booking được chuyển sang trạng thái PENDING chờ nhân viên xác nhận.

**Lịch cố định (UC09-UC12)**:
Khách hàng có thể tạo lịch đặt sân định kỳ (hàng ngày hoặc hàng tuần theo các ngày trong tuần chỉ định). Lịch cố định phải được nhân viên duyệt trước khi có hiệu lực. Sau khi duyệt, hệ thống tự động sinh booking cho từng buổi. Khách hàng có thể hủy một buổi cụ thể (exception date) hoặc hủy toàn bộ chuỗi.

**Tìm kiếm đối thủ / Ghép trận (UC13-UC16)**:
Đây là tính năng trọng tâm của hệ thống. Có hai hình thức: (1) **Manual**: người chơi tạo phòng công khai, chỉ định số người cần tuyển và chế độ đội, những người khác có thể tìm thấy và tham gia; (2) **Auto Queue**: người chơi vào hàng đợi với tiêu chí tìm kiếm, hệ thống tự động ghép các người chơi tương thích mỗi phút. Hỗ trợ 3 chế độ đội: INDIVIDUAL, TEAM_FILL, TEAM_VS_TEAM.

**Thanh toán (UC07-UC08)**:
Hỗ trợ hai phương thức: thanh toán tiền mặt tại quầy (STAFF xác nhận thu tiền qua web admin) và thanh toán trực tuyến qua ZaloPay (tích hợp WebView trong app). Kết quả thanh toán được xử lý qua callback server-side, đảm bảo tính toàn vẹn.

**Báo cáo thống kê (UC20-UC21)**:
ADMIN và STAFF có thể xem báo cáo hiệu suất sân (tỷ lệ lấp đầy, doanh thu theo sân) và dashboard tổng quan (xu hướng doanh thu, top sân, phân phối booking theo trạng thái) với bộ lọc linh hoạt theo thời gian và cơ sở.

---

### 3.3 Kiến trúc hệ thống

Hệ thống được xây dựng theo mô hình kiến trúc Client-Server đa tầng, với ba thành phần client độc lập (Flutter Android, React Web Admin) giao tiếp với một Backend thống nhất thông qua RESTful API và WebSocket (Socket.IO).

**Backend** được tổ chức theo kiến trúc phân lớp: Controller tiếp nhận và validate HTTP request, Service chứa toàn bộ business logic, Repository đóng gói truy vấn MongoDB, Model định nghĩa schema và ràng buộc dữ liệu. Các tác vụ nền được thực hiện bởi 4 cron job: tự động hủy booking quá hạn, tự động hoàn thành booking đã qua giờ chơi, ghép trận tự động mỗi phút, và sinh booking từ lịch cố định lúc 00:05 hàng đêm.

**Flutter mobile** áp dụng Clean Architecture với BLoC/Cubit pattern, tổ chức theo module tính năng độc lập (authentication_module, booking_module, matching_module, payment_module...). Dependency Injection được quản lý bởi `get_it`, routing bởi `go_router`.

**React Web Admin** sử dụng kiến trúc feature-based, tích hợp Ant Design cho UI component, TanStack React Query cho quản lý server state và caching.

---

## PHẦN 4: CÀI ĐẶT VÀ KIỂM THỬ

### 4.1 Môi trường phát triển

| Thành phần | Phiên bản | Mô tả |
|-----------|-----------|-------|
| Node.js | 18.x+ | Backend runtime |
| Flutter | 3.x (Dart ^3.12.0) | Mobile development |
| MongoDB Atlas | 7.x | Database as a Service |
| Android SDK | API 21+ (Android 5.0+) | Target Android |

### 4.2 Hướng dẫn cài đặt và chạy

#### Backend

```bash
cd node_be_refactor
npm install
cp .env.example .env   # Điền các biến môi trường
node src/main.js        # Hoặc npm start
```

Server khởi động ở port 3000 (mặc định). Truy cập `/health` để kiểm tra.

#### Flutter

```bash
cd sport_management/sports_management
flutter pub get
flutter run   # Chạy trên thiết bị/emulator đang kết nối
```

Cần cấu hình `google-services.json` cho Firebase và API base URL trong constants.

#### React Web

```bash
cd react-staff-admin
npm install
npm start    # Development server tại http://localhost:3000
```

---

### 4.3 Kịch bản kiểm thử

#### TC01 — Đăng ký và xác thực email

| Bước | Hành động | Kết quả mong đợi |
|------|-----------|-----------------|
| 1 | Nhập email chưa có trong hệ thống | Form hiển thị không có lỗi |
| 2 | POST `/auth/register { email, password, name }` | 201 Created, email OTP được gửi |
| 3 | POST `/auth/verify-email { email, otp }` (OTP đúng) | 200 OK, user status = ACTIVE |
| 4 | POST `/auth/sign-in { email, password }` | 200 OK, trả về accessToken + refreshToken |
| 5 | POST `/auth/verify-email { email, otp }` (OTP sai) | 400 INVALID_OTP |
| 6 | POST `/auth/register` với email đã tồn tại | 409 EMAIL_ALREADY_EXISTS |

#### TC02 — Đặt sân thành công

| Bước | Hành động | Kết quả mong đợi |
|------|-----------|-----------------|
| 1 | Đăng nhập với tài khoản CUSTOMER | Nhận accessToken |
| 2 | GET `/court?facility_id=...` | 200 OK, danh sách sân |
| 3 | GET `/court/:id/slot-config` | 200 OK, slot config |
| 4 | POST `/booking { court_id, booking_date, start_minutes: 540, end_minutes: 600 }` | 201 Created, booking PENDING |
| 5 | POST `/booking` lần 2 với cùng court+date+time | 409 SLOT_CONFLICT |
| 6 | STAFF: PUT `/booking/:id/status { status: CONFIRMED }` | 200 OK, booking CONFIRMED |
| 7 | Đợi 1 phút sau giờ end_minutes qua | Cron: booking COMPLETED tự động |

#### TC03 — Ghép trận thủ công

| Bước | Hành động | Kết quả mong đợi |
|------|-----------|-----------------|
| 1 | Host: POST `/matching { total_players_needed: 2, auto_approve: false }` | 201, session OPEN |
| 2 | Joiner: POST `/matching/:id/join { team_code: B }` | 200, member PENDING |
| 3 | Host: PUT `/matching/:id/members/:userId { status: APPROVED }` | 200, member APPROVED |
| 4 | Session có đủ 2 player | session status = FULL |
| 5 | Socket.IO emit `matching_session_updated` | Cả 2 client nhận update |

#### TC04 — Thanh toán ZaloPay

| Bước | Hành động | Kết quả mong đợi |
|------|-----------|-----------------|
| 1 | POST `/zalopay/create-order { paymentId }` | 200, trả về order_url |
| 2 | Flutter mở WebView với order_url | Trang ZaloPay Sandbox hiển thị |
| 3 | Thanh toán trên sandbox | ZaloPay gọi callback |
| 4 | Backend verify HMAC | Payment SUCCESS, Booking CONFIRMED |
| 5 | Polling: POST `/zalopay/query { paymentId }` | 200, `return_code: 1` |

#### TC05 — Lịch cố định

| Bước | Hành động | Kết quả mong đợi |
|------|-----------|-----------------|
| 1 | POST `/fixed-schedule { frequency: WEEKLY, days_of_week: [2,4,6] }` | 201, PENDING_APPROVAL |
| 2 | STAFF: PUT `/fixed-schedule/:id/approve` | 200, ACTIVE, bookings được sinh |
| 3 | GET `/booking?fixed_schedule_id=:id` | Danh sách booking đã sinh |
| 4 | POST `/fixed-schedule/:id/occurrences/2024-12-25/cancel` | exception_date added, booking ngày đó CANCELLED |
| 5 | PUT `/fixed-schedule/:id/pause` | PAUSED |
| 6 | Cron `fixedScheduler` chạy | Không sinh booking cho schedule PAUSED |
| 7 | PUT `/fixed-schedule/:id/resume` | ACTIVE |
| 8 | Cron chạy lại | Booking tiếp tục được sinh |

---

## PHẦN 5: KẾT LUẬN

### 5.1 Kết quả đạt được

Qua quá trình nghiên cứu và phát triển, đề tài đã đạt được các kết quả sau:

**Về mặt lý thuyết**, nhóm đã nghiên cứu và vận dụng thành công các công nghệ hiện đại trong phát triển phần mềm: kiến trúc microservice-ready (phân lớp Controller-Service-Repository), Clean Architecture trong Flutter, RESTful API design, tích hợp cổng thanh toán ZaloPay, xử lý thông báo thời gian thực với Socket.IO và Firebase FCM, và tự động hóa tác vụ với node-cron.

**Về mặt thực tiễn**, hệ thống đã triển khai thành công 30+ use case nghiệp vụ, bao gồm toàn bộ chu trình đặt sân từ xem thông tin → đặt sân → thanh toán → nhận thông báo → đánh giá; hệ thống lịch cố định tự động sinh booking; và đặc biệt là tính năng ghép trận với cả hai hình thức thủ công và tự động.

**Số liệu cụ thể**:
- 12 MongoDB schemas với 100+ fields được thiết kế
- 60+ API endpoints theo RESTful convention
- 4 cron jobs tự động hóa nghiệp vụ
- 25+ màn hình Flutter cho 3 nhóm người dùng
- 25+ trang web admin React với phân quyền ADMIN/STAFF
- Tích hợp 5 dịch vụ bên ngoài: MongoDB Atlas, Cloudinary, Firebase FCM, ZaloPay, Gmail SMTP

### 5.2 Hạn chế và hướng phát triển

Bên cạnh những kết quả đạt được, hệ thống còn một số hạn chế cần cải thiện trong tương lai: tích hợp thêm cổng thanh toán (VNPay, MoMo), hoàn thiện tính năng hoàn tiền tự động, bổ sung rate limiting chống tấn công, và triển khai Redis job queue để hỗ trợ mở rộng horizontal.

Hướng phát triển dài hạn có thể bao gồm: tích hợp trí tuệ nhân tạo để cải thiện thuật toán ghép trận dựa trên lịch sử trận đấu và kỹ năng người chơi; bổ sung tính năng chat/messaging giữa người chơi; và mở rộng sang nền tảng iOS và web dành cho khách hàng.

### 5.3 Lời kết

Hệ thống quản lý khu liên hợp thể thao tích hợp chức năng tìm kiếm đối thủ được phát triển trong khuôn khổ đồ án tốt nghiệp này thể hiện sự kết hợp toàn diện giữa kiến thức lý thuyết về phát triển phần mềm và kỹ năng thực hành xây dựng hệ thống thực tế. Tính năng ghép trận tự động — kết hợp giữa cơ chế tạo phòng thủ công và thuật toán ghép tự động dựa trên hàng đợi — là điểm sáng tạo đặc trưng của đề tài, giải quyết một nhu cầu thực sự của cộng đồng người chơi thể thao tại Việt Nam.
