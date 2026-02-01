/// API Configuration
/// Tập trung quản lý base URL và các config API

class ApiConfig {
  // Đổi thành IP máy chủ khi deploy
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Real device: IP của máy backend (VPS)
  static const String baseUrl = 'http://103.77.172.159:8080/api/';
  static const String signalRUrl = 'http://103.77.172.159:8080/pcmHub';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String auth = 'Auth';
  static const String members = 'Members';
  static const String wallet = 'Wallet';
  static const String courts = 'Courts';
  static const String bookings = 'Bookings';
  static const String tournaments = 'Tournaments';
  static const String notifications = 'Notifications';
  static const String upload = 'Upload';
  static const String matches = 'Matches';
}
