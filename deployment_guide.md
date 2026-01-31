# Hướng dẫn Triển khai Hệ thống PCM (VPS + Android APK)

Tài liệu này hướng dẫn chi tiết quy trình đưa hệ thống lên môi trường thực tế (Production).
**Quy trình bắt buộc:** `Frontend (VPS) --> Cập nhật IP --> Mobile (APK)`

---

## Phần 0: Chuẩn bị Môi trường (Nếu chưa có)
Để Build được ứng dụng Android (APK), máy tính **BẮT BUỘC** phải có **Android SDK**.
Nếu lệnh `flutter doctor` báo lỗi thiếu Android SDK, bạn cần làm như sau:

1. **Tải Android Studio**: [Tại đây](https://developer.android.com/studio)
2. **Cài đặt**: Chạy file cài đặt, chọn "Next" liên tục (giữ các tùy chọn mặc định).
3. **Cấu hình lần đầu**:
   - Mở Android Studio sau khi cài xong.
   - Nó sẽ hiện màn hình Setup Wizard -> Chọn **Standard** -> Next.
   - Nó sẽ tự động tải Android SDK (khoảng 1-2GB). Đợi cho xong và bấm Finish.
4. **Kiểm tra lại**: Mở terminal chạy `flutter doctor --android-licenses` và bấm `y` để đồng ý tất cả điều khoản.

---

## Phần 1: Deploy Backend lên VPS (Windows Server)

### Bước 1: Chuẩn bị trên máy cá nhân
1. Mở terminal tại thư mục Backend: `n:\Pickleball\Pcm.Api`
2. Chạy lệnh đóng gói (Publish) - *Đã thực hiện xong*:
   ```powershell
   dotnet publish -c Release -o ./publish
   ```
   **Mẹo:** Em đã nén sẵn thành file `Backend_Deploy.zip` trong thư mục `n:\Pickleball`. Bạn chỉ cần copy file này lên VPS.

### Bước 2: Đẩy code lên VPS
1. Remote Desktop (RDP) vào VPS:
   - IP: `103.77.172.159`
   - User/Pass: (Đã có)
2. Cài đặt **.NET 9.0 Hosting Bundle** trên VPS (nếu chưa có).
3. Giải nén file `Backend_Deploy.zip` vào `C:\inetpub\wwwroot\PcmApi`.

### Bước 3: Cấu hình IIS (Internet Information Services)
1. Mở **IIS Manager** trên VPS.
2. Tạo mới **Website**:
   - **Site name**: PcmApi
   - **Physical path**: `C:\inetpub\wwwroot\PcmApi`
   - **Port**: 80
3. Cấu hình **Application Pool**: Chọn `.NET CLR Version` là `No Managed Code`.
4. Tìm file `appsettings.json`, sửa `ConnectionStrings` trỏ vào SQL Server trên VPS.

---

## Phần 2: Build Android APK
*(Chỉ thực hiện được sau khi đã cài xong Android Studio ở Phần 0)*

### Bước 1: Cấu hình IP
*Đã cập nhật IP VPS `103.77.172.159` vào file cấu hình Mobile.*

### Bước 2: Tạo file APK
1. Mở terminal tại `n:\Pickleball\pcm_mobile`
2. Chạy lệnh:
   ```powershell
   flutter build apk --release
   ```
3. File kết quả: `build\app\outputs\flutter-apk\app-release.apk`
