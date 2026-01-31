import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../core/services/biometric_service.dart';
import 'main_layout.dart';

import 'register_screen.dart';

/// Login Screen - Màn hình đăng nhập premium
/// Thiết kế: Glassmorphism + Gradient background + Animations

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _biometricService = BiometricService();
  bool _obscurePassword = true;
  bool _isBiometricSupported = false;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final supported = await _biometricService.isBiometricAvailable();
    if (mounted) setState(() => _isBiometricSupported = supported);
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      // Demo: Trong thực tế sẽ lấy token đã lưu hoặc gọi API đặc biệt
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    
    if (mounted) {
      if (success) {
        // Navigate based on role
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(authProvider.error ?? 'Đăng nhập thất bại')),
              ],
            ),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1F33),
              Color(0xFF1E3A5F),
              Color(0xFF0A0E14),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      _buildLogo(),
                      const SizedBox(height: 40),
                      
                      // Login Card with Glassmorphism
                      _buildLoginCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Register Link
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Animated Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_tennis,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'PCM PICKLEBALL',
          style: AppTheme.heading1.copyWith(
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: AppColors.accent.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'VỢT THỦ PHỐ NÚI',
          style: AppTheme.bodyMedium.copyWith(
            letterSpacing: 5,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Đăng nhập',
                  style: AppTheme.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tài khoản',
                    hintText: 'Nhập tên đăng nhập',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.accent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tài khoản';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                
                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'ĐĂNG NHẬP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
                
                if (_isBiometricSupported) ...[
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint, color: AppColors.accent, size: 32),
                    label: Text(
                      'Đăng nhập bằng sinh trắc học',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: AppTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(
            'Đăng ký ngay',
            style: AppTheme.bodyLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
