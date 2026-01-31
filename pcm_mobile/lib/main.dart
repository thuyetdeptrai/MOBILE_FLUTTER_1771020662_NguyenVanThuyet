import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/core.dart';
import 'core/services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Hive cho Offline Cache
  await Hive.initFlutter();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PCM Pickleball',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// AuthWrapper - Kiểm tra trạng thái đăng nhập và điều hướng
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_tennis, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.accent),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoggedIn) {
          return const MainLayout();
        }
        return const LoginScreen();
      },
    );
  }
}
