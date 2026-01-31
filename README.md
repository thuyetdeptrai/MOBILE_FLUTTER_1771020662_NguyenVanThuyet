# Pickleball Management System (PCM) - Hướng dẫn vận hành

Hệ thống quản lý Pickleball (PCM) đã được triển khai lên VPS và sẵn đóng tải ứng dụng Mobile.

---

## 1. Thông tin Hệ thống (Production)

- **IP Máy chủ (VPS)**: `103.77.172.159`
- **Hệ điều hành**: Ubuntu 22.04 LTS
- **Backend API**: [http://103.77.172.159/api/](http://103.77.172.159/api/)
- **Cơ sở dữ liệu**: MSSQL Server 2022 (Chạy trong Docker)
- **Tải ứng dụng Android (APK)**: [http://103.77.172.159/apk/app-release.apk](http://103.77.172.159/apk/app-release.apk)

---

## 2. Hướng dẫn dành cho Người dùng Mobile

1.  Truy cập link [tải APK](http://103.77.172.159/apk/app-release.apk) bằng trình duyệt điện thoại Android.
2.  Sau khi tải xong, mở file để cài đặt. (Lưu ý: Bạn có thể cần cho phép "Cài đặt từ nguồn không xác định").
3.  Mở ứng dụng và đăng nhập bằng tài khoản mẫu:
    - **Admin**: `admin@pcm.vn` / mật khẩu: `Admin@123`
    - **Thành viên**: `member01@pcm.vn` / mật khẩu: `Member@123`

---

## 3. Hướng dẫn Quản trị (Dành cho Dev)

### Kết nối vào VPS
Sử dụng SSH key có sẵn trong thư mục dự án:
```powershell
ssh -i .\temp_key root@103.77.172.159
```

### Quản lý Backend Service
Ứng dụng chạy dưới dạng service trên Ubuntu. Các lệnh quan trọng:
- **Kiểm tra trạng thái**: `systemctl status pcm-api`
- **Khởi động lại**: `systemctl restart pcm-api`
- **Xem log trực tiếp**: `journalctl -u pcm-api -f`

### Quản lý Database (Docker)
Cơ sở dữ liệu chạy trong container tên `sql1`.
- **Xem trạng thái**: `docker ps`
- **Xem log DB**: `docker logs sql1`
- **Thông tin đăng nhập DB**:
  - Host: `localhost,1433`
  - User: `sa`
  - Pass: `Pcm@2026Strong!`

---

## 4. Cập nhật và Triển khai lại (Redeploy)

Nếu bạn sửa code và muốn đẩy lên lại, hãy thực hiện các bước sau:

### Backend:
1. Mở terminal tại `Pcm.Api`.
2. Chạy lệnh publish:
   ```powershell
   dotnet publish -c Release -r linux-x64 --self-contained false -o ../publish_linux
   ```
3. Nén thư mục `publish_linux` và SCP lên VPS, sau đó restart service `pcm-api`.

### Mobile:
1. Mở terminal tại `pcm_mobile`.
2. Chạy lệnh: `flutter build apk --release`.
3. Copy file `build\app\outputs\flutter-apk\app-release.apk` lên thư mục `/var/www/html/apk/` trên VPS.

---

## 5. Cấu trúc Thư mục Dự án
- `Pcm.Api/`: Mã nguồn Backend (ASP.NET Core 9.0).
- `pcm_mobile/`: Mã nguồn Ứng dụng di động (Flutter).
- `PCM_Solution.sln`: File solution để mở bằng Visual Studio.
- `temp_key`: Key bảo mật để kết nối SSH vào VPS.
