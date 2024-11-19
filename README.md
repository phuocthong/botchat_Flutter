# Potter-GPT Flutter Application

**Potter-GPT** là một ứng dụng chatbot sử dụng Flutter, tích hợp Firebase để quản lý người dùng và cung cấp tính năng gửi, nhận tin nhắn.

## 📱 **Tính năng**
- Đăng nhập/Đăng xuất bằng Firebase Authentication.
- Gửi và nhận tin nhắn với chatbot.
- Chuyển đổi giữa chế độ **Light** và **Dark**.
- Giao diện thân thiện và dễ sử dụng.

---

## 🛠 **Cài đặt và sử dụng**

### 1️⃣ Yêu cầu hệ thống:
- Flutter SDK >= 3.0
- Dart >= 2.18
- Firebase Project
- VS Code hoặc Android Studio

### 2️⃣ Cài đặt:
1. Clone repository này:
   git clone https://github.com/phuocthong/botchat_Flutter
   
2. Cài đặt các gói phụ thuộc:
flutter pub get

3. Cấu hình Firebase:
- Tạo dự án trên Firebase.
- Thêm tệp google-services.json (Android) và GoogleService-Info.plist (iOS) vào thư mục tương ứng.
- Đảm bảo các tệp được khai báo trong pubspec.yaml.

4. Cấu hình API (nếu có sử dụng):
Tạo file .env tại thư mục gốc:
API_KEY=your-api-key

5. Chạy ứng dụng:
flutter run
