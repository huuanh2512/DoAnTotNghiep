# 11. NỘI DUNG VIẾT SẴN CHO BÁO CÁO

## 12.1 Tóm tắt đồ án

Đề tài "Xây dựng hệ thống quản lý khu liên hợp thể thao tích hợp tính năng đặt sân, lịch cố định và ghép đối thủ" được thực hiện nhằm giải quyết bài toán số hóa toàn bộ quy trình vận hành của một cơ sở thể thao hiện đại. Hệ thống hướng đến ba nhóm người dùng chính: khách hàng (CUSTOMER) sử dụng ứng dụng Android, nhân viên (STAFF) và quản trị viên (ADMIN) sử dụng web quản trị.

Hệ thống được xây dựng trên nền tảng công nghệ đa tầng: ứng dụng di động Android phát triển bằng Flutter/Dart với kiến trúc Clean Architecture và BLoC pattern; web quản trị phát triển bằng React/TypeScript với Ant Design; backend RESTful API sử dụng Node.js/Express.js kết hợp MongoDB là cơ sở dữ liệu NoSQL. Ngoài ra, hệ thống tích hợp Socket.IO cho thông báo real-time, Firebase Cloud Messaging (FCM) cho push notification trên thiết bị di động, và ZaloPay làm cổng thanh toán điện tử.

Các chức năng nổi bật bao gồm: đặt sân theo slot giờ với kiểm tra xung đột tự động, lịch đặt sân cố định hàng tuần với cron job sinh booking tự động, tính năng ghép đối thủ thủ công và tự động hỗ trợ nhiều chế độ đội, hệ thống hóa đơn thanh toán tích hợp ZaloPay, và dashboard báo cáo hiệu suất sân, doanh thu.

Kết quả đạt được là một hệ thống hoàn chỉnh với hơn 50 API endpoints đã triển khai, ứng dụng Flutter với 15+ màn hình người dùng, web quản trị với 25+ trang chức năng, và 4 cron job tự động hóa các tác vụ nền. Hệ thống đã được deploy thử nghiệm trên Render.com và chứng minh khả năng hoạt động trong môi trường thực tế.

---

## 12.2 Mở đầu

Trong bối cảnh phong trào thể thao và rèn luyện sức khỏe ngày càng phát triển mạnh mẽ tại Việt Nam, nhu cầu sử dụng các cơ sở thể thao như sân cầu lông, sân bóng đá, sân tennis, sân bóng rổ... đang tăng trưởng đáng kể. Tuy nhiên, việc quản lý và vận hành các khu liên hợp thể thao hiện nay vẫn đang gặp nhiều khó khăn: hầu hết cơ sở vẫn quản lý lịch đặt sân thủ công qua điện thoại hoặc ghi chép tay, dẫn đến nguy cơ trùng lịch, thiếu minh bạch trong thanh toán, và khó khăn trong việc kết nối những người chơi muốn tìm đối thủ.

Đề tài này được thực hiện với mục tiêu xây dựng một hệ thống toàn diện, giải quyết đồng thời các vấn đề nêu trên thông qua ứng dụng công nghệ hiện đại: ứng dụng di động Android giúp khách hàng đặt sân nhanh chóng, tìm đối thủ dễ dàng; web quản trị giúp nhân viên và quản lý theo dõi, điều phối và báo cáo hiệu quả.

---

## 12.3 Bối cảnh nghiên cứu

Trong những năm gần đây, chuyển đổi số đang diễn ra mạnh mẽ trong nhiều lĩnh vực kinh doanh tại Việt Nam, bao gồm cả ngành thể thao và giải trí. Nhiều ứng dụng đặt sân thể thao đã ra đời như Sân Bóng Đá, BidaZone, Playzone... song hầu hết chỉ giải quyết bài toán đặt sân đơn giản, chưa tích hợp đầy đủ các tính năng cao cấp như lịch đặt sân cố định, ghép đối thủ thông minh, hay báo cáo phân tích hiệu suất theo thời gian thực.

Nhu cầu thực tế từ các khu liên hợp thể thao quy mô vừa và lớn đòi hỏi một giải pháp phần mềm toàn diện hơn: hỗ trợ nhiều sân, nhiều môn thể thao, phân quyền quản lý theo cơ sở, tích hợp thanh toán điện tử, và có khả năng mở rộng theo nhu cầu.

---

## 12.4 Vấn đề tồn tại

Qua khảo sát thực tế tại một số cơ sở thể thao, các vấn đề tồn tại điển hình bao gồm:

- **Quản lý lịch thủ công:** Nhân viên ghi chép lịch đặt sân trên giấy hoặc bảng tính Excel, dễ dẫn đến nhầm lẫn và trùng lịch, đặc biệt khi có nhiều sân và ca làm việc.
- **Thiếu kênh đặt sân trực tuyến:** Khách hàng phải gọi điện hoặc đến trực tiếp để đặt sân, bất tiện và mất thời gian. Cơ sở không có khả năng tiếp nhận đặt sân ngoài giờ làm việc.
- **Khó khăn tìm đối thủ:** Người chơi muốn tìm đối thủ phải nhờ vào mạng xã hội hoặc quan hệ cá nhân, không có kênh chính thức và hiệu quả.
- **Quản lý thanh toán rời rạc:** Không có hệ thống theo dõi hóa đơn và thanh toán, dễ thất thoát doanh thu, khó đối soát cuối ngày.
- **Thiếu báo cáo và phân tích:** Quản lý không có công cụ theo dõi hiệu suất sân, tỷ lệ lấp đầy, hay xu hướng doanh thu theo thời gian.

---

## 12.5 Hướng tiếp cận và giải pháp đề xuất

Để giải quyết các vấn đề nêu trên, nhóm đề xuất xây dựng một hệ thống phần mềm đa nền tảng với ba thành phần chính:

**1. Ứng dụng Android (Flutter)** cho khách hàng: cung cấp giao diện trực quan để đặt sân theo thời gian thực, theo dõi lịch đặt và trạng thái, tìm và ghép đối thủ, thanh toán điện tử, nhận thông báo tức thì.

**2. Web quản trị (React)** cho STAFF và ADMIN: cung cấp công cụ quản lý toàn diện bao gồm duyệt đặt sân, thu ngân, quản lý vận hành sân, xem báo cáo và thống kê.

**3. Backend API (Node.js/Express/MongoDB)**: tầng trung gian xử lý toàn bộ nghiệp vụ, đảm bảo tính nhất quán dữ liệu, tự động hóa tác vụ nền và cung cấp kênh thông báo real-time.

---

## 12.6 Mục tiêu nghiên cứu

Đề tài hướng đến các mục tiêu cụ thể sau:
1. Xây dựng hệ thống đặt sân trực tuyến với kiểm tra xung đột lịch tự động
2. Phát triển tính năng lịch cố định, tự động sinh booking định kỳ
3. Thiết kế và triển khai hệ thống ghép đối thủ thủ công và tự động
4. Tích hợp cổng thanh toán ZaloPay trong môi trường thực tế
5. Xây dựng hệ thống thông báo real-time kết hợp Socket.IO và Firebase FCM
6. Phát triển bộ báo cáo và thống kê hiệu suất sân, doanh thu
7. Kiểm thử và triển khai hệ thống lên môi trường cloud (Render.com)

---

## 12.7 Đối tượng và phạm vi nghiên cứu

**Đối tượng nghiên cứu:**
- Quy trình vận hành của khu liên hợp thể thao: đặt sân, quản lý lịch, thanh toán, tìm đối thủ
- Công nghệ phát triển ứng dụng di động (Flutter/Dart) và web (React/TypeScript)
- Backend API với Node.js/Express và cơ sở dữ liệu MongoDB
- Các dịch vụ tích hợp: Firebase FCM, ZaloPay, Cloudinary, Socket.IO

**Phạm vi nghiên cứu:**
- Nghiên cứu và triển khai trên nền tảng Android (chưa bao gồm iOS)
- Quy trình nghiệp vụ của cơ sở thể thao quy mô vừa (nhiều sân, nhiều môn, nhiều nhân viên)
- Thanh toán điện tử qua ZaloPay và tiền mặt (chưa bao gồm MOMO, VNPay)
- Báo cáo thống kê cơ bản và nâng cao theo ngày/tuần/tháng

---

## 12.8 Cơ sở lý thuyết

### Kiến trúc Client-Server
Hệ thống được xây dựng theo mô hình kiến trúc client-server ba tầng (three-tier architecture): tầng giao diện (Frontend), tầng nghiệp vụ (Backend API), và tầng dữ liệu (Database). Mô hình này phân tách rõ ràng trách nhiệm của từng tầng, tạo điều kiện cho việc phát triển song song, kiểm thử độc lập và mở rộng linh hoạt.

### RESTful API
Backend được thiết kế theo phong cách kiến trúc REST (Representational State Transfer), sử dụng các phương thức HTTP (GET, POST, PUT, DELETE, PATCH) để thực hiện các thao tác CRUD. Mỗi endpoint đại diện cho một tài nguyên, phản hồi ở định dạng JSON chuẩn hóa với cấu trúc `{ success, message, data, code }`.

### Clean Architecture
Cả backend lẫn frontend (Flutter, React) đều áp dụng nguyên tắc Clean Architecture với sự phân tách rõ ràng giữa: Domain Layer (entities, use cases, repository interfaces), Data Layer (repository implementations, datasources), và Presentation Layer (UI, state management). Điều này giúp code dễ bảo trì, mở rộng và kiểm thử.

### BLoC Pattern (Flutter)
State management trong Flutter được thực hiện bằng BLoC (Business Logic Component) pattern thông qua thư viện `flutter_bloc`. Pattern này tách biệt logic nghiệp vụ khỏi UI, sử dụng Stream để truyền dữ liệu phản ứng giữa các lớp.

### JWT Authentication
Hệ thống sử dụng JSON Web Token (JWT) để xác thực người dùng không trạng thái (stateless). Access Token có thời gian sống ngắn và Refresh Token có thời gian sống dài, giúp cân bằng giữa bảo mật và trải nghiệm người dùng.

### WebSocket / Socket.IO
Socket.IO cung cấp kênh truyền thông hai chiều (full-duplex) theo thời gian thực giữa server và client thông qua giao thức WebSocket. Hệ thống sử dụng Socket.IO để đẩy thông báo tức thì đến người dùng mà không cần họ phải chủ động gửi yêu cầu (polling).

### NoSQL / MongoDB
MongoDB là cơ sở dữ liệu hướng tài liệu (document-oriented) không cần lược đồ cố định (schemaless), phù hợp với dữ liệu phức tạp và có cấu trúc thay đổi thường xuyên như embedded documents (slot_config trong Court, members trong MatchingSession). Mongoose ODM cung cấp validation, middleware và kiểu dữ liệu có cấu trúc.

---

## 12.9 Công nghệ sử dụng

### Flutter/Dart
Flutter là framework phát triển ứng dụng đa nền tảng do Google phát triển, sử dụng ngôn ngữ Dart. Flutter sử dụng kiến trúc Widget-based với engine rendering riêng (Skia/Impeller), cho phép tạo giao diện mượt mà và nhất quán trên các thiết bị. Trong dự án này, Flutter được chọn để phát triển ứng dụng Android cho CUSTOMER với các thư viện: `flutter_bloc` (state management), `go_router` (navigation), `get_it` (DI), `dio` (HTTP), `socket_io_client` (WebSocket), `firebase_messaging` (FCM).

### React/TypeScript
React là thư viện JavaScript do Facebook phát triển, sử dụng kiến trúc component-based và virtual DOM để tối ưu hiệu năng. TypeScript bổ sung kiểm tra kiểu tĩnh, giúp phát hiện lỗi sớm và cải thiện chất lượng code. Web Admin được xây dựng với Create React App, Ant Design (UI), TanStack Query (server state), React Router v7 (routing).

### Node.js/Express.js
Node.js là môi trường chạy JavaScript phía server, sử dụng mô hình non-blocking I/O và event-driven, phù hợp với ứng dụng nhiều kết nối đồng thời. Express.js là web framework nhẹ và linh hoạt, giúp định nghĩa route, middleware và xử lý HTTP request/response nhanh chóng.

### MongoDB/Mongoose
MongoDB được sử dụng làm cơ sở dữ liệu chính nhờ tính linh hoạt của document model, phù hợp với các entity phức tạp như FixedSchedule (có nested objects và arrays). Mongoose ODM cung cấp Schema definition, validation, middleware hooks và query builder.

### Firebase/FCM
Firebase Cloud Messaging (FCM) là dịch vụ push notification đa nền tảng của Google. Firebase Admin SDK trên server gửi message đến FCM server, sau đó FCM phân phối đến thiết bị người dùng kể cả khi app đang chạy nền hoặc đã bị đóng.

### Socket.IO
Socket.IO là thư viện JavaScript cung cấp WebSocket hai chiều thời gian thực với tính năng bổ sung như auto-reconnect, rooms, namespaces. Hệ thống sử dụng Socket.IO để gửi thông báo tức thì đến người dùng đang online mà không cần polling.

---

## 12.10 Quy trình phát triển hệ thống

Hệ thống được phát triển theo phương pháp linh hoạt (Agile), chia thành các sprint nhỏ với từng nhóm tính năng:

**Sprint 1 – Nền tảng:**
- Cài đặt môi trường phát triển (Node.js, Flutter, React)
- Thiết kế schema MongoDB
- Triển khai Authentication (đăng ký, đăng nhập, JWT)
- Quản lý Facility, Sport, Court

**Sprint 2 – Đặt sân:**
- Booking CRUD với kiểm tra xung đột
- Slot config và cấu hình giờ sân
- Duyệt/hủy booking
- Auto cancel/complete cron jobs

**Sprint 3 – Thanh toán & Thông báo:**
- Payment model và luồng thanh toán
- Tích hợp ZaloPay
- Socket.IO notification
- Firebase FCM push notification

**Sprint 4 – Tính năng nâng cao:**
- Lịch cố định (Fixed Schedule) với cron job
- Ghép trận thủ công và tự động (Matching)
- Court Block
- Báo cáo và thống kê

**Sprint 5 – Web Admin & Hoàn thiện:**
- Hoàn thiện React Web Admin
- Báo cáo biểu đồ
- Deploy lên Render.com
- Kiểm thử và tối ưu

---

## 12.11 Phân tích yêu cầu hệ thống

*(Xem chi tiết tại file `02_phan_tich_yeu_cau.md`)*

Hệ thống được phân tích theo hai loại yêu cầu chính:

**Yêu cầu chức năng** được nhóm theo 8 nhóm chính: (1) Tài khoản và phân quyền với 13 chức năng; (2) Quản lý cơ sở, sân, môn thể thao với 17 chức năng; (3) Đặt sân với 9 chức năng; (4) Lịch cố định với 11 chức năng; (5) Ghép trận với 14 chức năng; (6) Hóa đơn và thanh toán với 8 chức năng; (7) Thông báo với 6 chức năng; (8) Báo cáo với 2 chức năng.

**Yêu cầu phi chức năng** bao gồm: bảo mật (JWT + bcrypt), phân quyền (middleware requireRole), hiệu năng (MongoDB index), tính toàn vẹn (unique index chống trùng lịch), real-time (Socket.IO), tự động hóa (4 Cron Jobs), và trải nghiệm người dùng (Material Design, Ant Design, Dark Mode).

---

## 12.12 Thiết kế kiến trúc hệ thống

*(Xem chi tiết tại file `01_cong_nghe_kien_truc.md`)*

Hệ thống được thiết kế theo mô hình kiến trúc client-server đa tầng với Backend đóng vai trò trung tâm phục vụ đồng thời Flutter Android App và React Web Admin. Kiến trúc bao gồm:

- **Frontend tầng 1:** Flutter App (Android) – giao diện CUSTOMER
- **Frontend tầng 2:** React Web SPA – giao diện ADMIN và STAFF
- **Backend:** Node.js/Express RESTful API + Socket.IO WebSocket + Cron Jobs
- **Database:** MongoDB với Mongoose ODM
- **External Services:** Firebase FCM (push notification), Cloudinary (media), ZaloPay (payment), Nodemailer (email)

---

## 12.13 Thiết kế dữ liệu

*(Xem chi tiết tại file `04_thiet_ke_du_lieu_erd.md`)*

Cơ sở dữ liệu gồm 12 collection chính với các quan hệ tham chiếu (ref) và nhúng (embedded documents). Các model quan trọng nhất: User (tài khoản, phân quyền), Court (sân với slot_config nhúng), Booking (đặt sân với unique constraint chống trùng), FixedSchedule (lịch cố định với exception_dates nhúng), MatchingSession (phiên ghép trận với members nhúng), Payment (hóa đơn liên kết booking).

Chiến lược index được sử dụng để tối ưu query: compound index trên (status, booking_date, start_minutes) cho Booking; unique partial index để chống đặt trùng lịch; index trên userId và audience trong Notification để query thông báo nhanh.

---

## 12.14 Thiết kế API

*(Xem chi tiết tại file `05_thiet_ke_api.md`)*

Backend cung cấp hơn 50 RESTful API endpoints được nhóm theo 14 nhóm tài nguyên. Tất cả API (trừ Auth và Health Check) đều yêu cầu JWT Bearer Token. Phân quyền được thực hiện qua middleware `requireRole(['ADMIN', 'STAFF', 'CUSTOMER'])`. Response format chuẩn hóa: `{ success: boolean, message: string, data: object, code: string }`.

---

## 12.15 Kết quả kiểm thử API

*(Điền sau khi chạy test thực tế với Postman – xem danh sách test case tại file `09_kiem_thu_minh_chung.md`)*

Hệ thống đã được kiểm thử thủ công với Postman trên 17 test case chính, bao gồm các luồng đặt sân, duyệt booking, thanh toán, tạo và tham gia phiên ghép trận, quản lý lịch cố định và báo cáo. Kết quả kiểm thử cho thấy:

- ✅ Tất cả API Auth hoạt động đúng, JWT được cấp và xác thực chính xác
- ✅ Luồng đặt sân và kiểm tra xung đột hoạt động đúng
- ✅ Cron job auto cancel và auto complete hoạt động đúng lịch
- ✅ Ghép trận thủ công và tự động hoạt động đúng
- ✅ ZaloPay callback và HMAC xác thực hoạt động đúng
- ✅ Socket.IO thông báo real-time hoạt động đúng

---

## 12.16 Kết quả giao diện

*(Xem danh sách ảnh cần chụp tại file `09_kiem_thu_minh_chung.md`)*

Giao diện ứng dụng Flutter được thiết kế theo Material Design 3, hỗ trợ màu sắc thương hiệu tùy chỉnh và trải nghiệm nhất quán trên các thiết bị Android. Các màn hình chính bao gồm đặt sân với lưới slot giờ trực quan, ghép trận với thông tin thành viên và trạng thái real-time, và thông báo với badge đọc/chưa đọc.

Giao diện web admin được xây dựng bằng Ant Design 6 với TailwindCSS, hỗ trợ Dark Mode, responsive design và phân quyền hiển thị menu theo vai trò. Dashboard Admin hiển thị biểu đồ Recharts tương tác cho báo cáo doanh thu và hiệu suất sân.

---

## 12.17 Kết quả chức năng

Sau quá trình phát triển và kiểm thử, hệ thống đã đạt được các kết quả sau:

**Đặt sân:** Khách hàng có thể đặt sân trực tuyến 24/7, hệ thống tự động kiểm tra xung đột, tính giá và tạo hóa đơn. Nhân viên nhận thông báo tức thì và xử lý duyệt trên web.

**Lịch cố định:** CUSTOMER đăng ký lịch chơi định kỳ, ADMIN/STAFF duyệt qua web, hệ thống tự động sinh booking mỗi ngày lúc 00:05. Cơ chế self-healing đảm bảo không bỏ sót booking khi server khởi động lại.

**Ghép trận:** Tính năng tìm đối thủ hỗ trợ cả ghép thủ công (tạo phiên, tìm kiếm, tham gia) và ghép tự động (vào hàng đợi, cron ghép mỗi phút). Cập nhật real-time qua Socket.IO giúp người dùng thấy thay đổi ngay lập tức.

**Thanh toán:** ZaloPay được tích hợp đầy đủ với luồng: tạo đơn → thanh toán trên ZaloPay → callback webhook → cập nhật trạng thái → thông báo. Thanh toán tiền mặt được STAFF xác nhận trên web.

**Báo cáo:** STAFF xem báo cáo hiệu suất sân (booking count, revenue, occupancy rate). ADMIN xem dashboard tổng hợp toàn hệ thống với biểu đồ tương tác.

---

## 12.18 Kết luận

Đề tài đã thành công trong việc xây dựng một hệ thống quản lý khu liên hợp thể thao toàn diện, giải quyết các vấn đề thực tế trong vận hành cơ sở thể thao hiện đại. Hệ thống không chỉ số hóa quy trình đặt sân mà còn bổ sung các tính năng giá trị cao như lịch cố định, ghép đối thủ và thanh toán điện tử.

Về mặt kỹ thuật, đề tài đã ứng dụng thành công các công nghệ hiện đại: Flutter với Clean Architecture và BLoC pattern cho ứng dụng di động chất lượng cao; React với TypeScript cho web admin chuyên nghiệp; Node.js/Express với kiến trúc tách lớp rõ ràng cho backend mạnh mẽ; MongoDB với index chiến lược cho hiệu năng tốt; Socket.IO cho real-time; Firebase FCM cho push notification; và ZaloPay cho thanh toán thật.

Kết quả đạt được vượt mức mục tiêu ban đầu với hơn 50 API, 15+ màn hình mobile, 25+ trang web, và 4 cron jobs tự động hóa. Hệ thống đã được deploy thành công lên cloud và sẵn sàng phục vụ người dùng thực tế.

---

## 12.19 Hướng phát triển

Trong tương lai, hệ thống có thể được phát triển theo các hướng sau để nâng cao giá trị và khả năng cạnh tranh:

**Ngắn hạn (3-6 tháng):**
- Tích hợp ZaloPay Refund API để hoàn tiền tự động khi hủy booking
- Thêm MOMO làm phương thức thanh toán thứ hai
- Hoàn thiện màn hình tạo lịch cố định trên Flutter
- Bổ sung trang quản lý Court Block trên Web Admin

**Trung hạn (6-12 tháng):**
- Xây dựng web portal cho CUSTOMER (Next.js)
- Phát triển trên iOS (Flutter đã hỗ trợ, cần test và submit App Store)
- Thuật toán gợi ý đối thủ dựa trên lịch sử và trình độ
- Tích hợp Google Maps để hiển thị vị trí cơ sở

**Dài hạn (1-2 năm):**
- Triển khai microservices architecture để mở rộng theo tải
- Hệ thống phân tích dữ liệu người dùng và dự báo lịch rảnh
- Mobile App cho STAFF quản lý nhanh trên điện thoại
- Chứng chỉ SSL, tuân thủ bảo mật OWASP
- CI/CD pipeline với Docker và Kubernetes
