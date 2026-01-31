import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

/// Auth Provider - Quản lý trạng thái đăng nhập
/// Lưu JWT token và thông tin user

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get userId => _currentUser?.id ?? '';
  double get walletBalance => _currentUser?.walletBalance ?? 0;
  String get tier => _currentUser?.tier ?? 'Standard';
  
  /// Đăng nhập
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        '${ApiConfig.auth}/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Lưu token
        if (data['token'] != null) {
          await _apiService.saveToken(data['token']);
        }
        
        // Tạo user object
        _currentUser = User.fromJson(data);
        
        // Lưu user info locally
        await _storage.write(key: 'user_data', value: jsonEncode(_currentUser!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Sai tài khoản hoặc mật khẩu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi kết nối: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Đăng ký
  Future<bool> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        '${ApiConfig.auth}/register',
        data: {
          'username': username,
          'password': password,
          'fullName': fullName,
          'email': email,
        },
      );
      
      _isLoading = false;
      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        _error = response.data?.toString() ?? 'Đăng ký thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi kết nối: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Đăng xuất
  Future<void> logout() async {
    await _apiService.clearToken();
    await _storage.delete(key: 'user_data');
    _currentUser = null;
    notifyListeners();
  }
  
  /// Kiểm tra đăng nhập từ storage
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _apiService.getToken();
      final userData = await _storage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
    }
    return false;
  }
  
  /// Cập nhật số dư ví
  void updateWalletBalance(double newBalance) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(walletBalance: newBalance);
      notifyListeners();
    }
  }
  
  /// Cập nhật thông tin user
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
  
  /// Refresh user profile từ API  
  Future<void> refreshProfile() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _apiService.get('${ApiConfig.wallet}/${_currentUser!.id}');
      if (response.statusCode == 200) {
        final data = response.data;
        _currentUser = _currentUser!.copyWith(
          walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? _currentUser!.walletBalance,
          tier: data['tier'] ?? _currentUser!.tier,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh profile error: $e');
    }
  }
}
