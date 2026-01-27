import 'dart:convert'; // Để xử lý JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Thư viện mạng
import 'home_screen.dart';
import 'admin_screen.dart'; // Đảm bảo đã import trang Admin
import 'register_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Biến để xoay vòng tròn khi đang tải

  // Hàm xử lý Đăng nhập
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true; // Bắt đầu xoay
    });

    // Lấy thông tin từ ô nhập
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Địa chỉ API (Lưu ý: localhost của máy tính)
    // Nếu chạy Web: dùng 'http://localhost:5176/api/Auth/login'
    // Nếu chạy Máy ảo Android: dùng 'http://10.0.2.2:5176/api/Auth/login'
    const String apiUrl = 'http://localhost:5176/api/Auth/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Đăng nhập thành công
        final data = jsonDecode(response.body);
        final fullName = data['fullName'];

        if (mounted) {
          // --- LOGIC PHÂN QUYỀN MỚI ---
          if (username == 'admin') {
            // Nếu là admin -> Chuyển sang trang Quản trị
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          } else {
            // Nếu là user thường -> Chuyển sang trang Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(fullName: fullName, userId: data['userId']),
              ),
            );
          }
          // -----------------------------
        }
      } else {
        // Đăng nhập thất bại
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sai tài khoản hoặc mật khẩu!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Lỗi mạng hoặc lỗi server
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false; // Tắt xoay
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.sports_tennis, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'PCM PICKLEBALL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Tài khoản',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // Nút bấm có hiệu ứng Loading
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _handleLogin, // Nếu đang load thì khóa nút
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            // Thêm vào dưới nút Đăng nhập
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
            )
          ],
        ),
      ),
    );
  }
}
