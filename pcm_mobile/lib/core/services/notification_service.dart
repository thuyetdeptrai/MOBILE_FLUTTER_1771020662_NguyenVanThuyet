import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:signalr_netcore/signalr_netcore.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

/// Service quản lý thông báo (SignalR tạm tắt fix lỗi compilation)
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  final ApiService _api = ApiService();
  final List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  String? _userId;
  
  final StreamController<double> _balanceController = StreamController<double>.broadcast();
  Stream<double> get onBalanceChanged => _balanceController.stream;
  
  // SignalR
  // HubConnection? _hubConnection;
  bool _isConnected = false;
  
  NotificationService._internal();
  
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isConnected => _isConnected;
  
  /// Khởi tạo service
  Future<void> initialize(String userId) async {
    _userId = userId;
    await fetchNotifications();
    await _initSignalR();
    
    debugPrint('✅ NotificationService initialized for user: $userId');
  }
  
  Future<void> _initSignalR() async {
    /* TODO: Fix SignalR package issue on Windows
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }
    
    String hubUrl = ApiConfig.baseUrl.replaceAll('/api', '/pcmHub');
    if (defaultTargetPlatform == TargetPlatform.android && hubUrl.contains('localhost')) {
      hubUrl = hubUrl.replaceAll('localhost', '10.0.2.2');
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();
        
    _hubConnection!.onclose(({error}) {
      _isConnected = false;
      notifyListeners();
    });
    
    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected = true;
      if (_userId != null) {
        _hubConnection!.invoke("JoinRoom", args: [_userId]);
      }
      notifyListeners();
    });

    _hubConnection!.on("ReceiveNotification", _handleNewNotification);
    
    try {
      await _hubConnection!.start();
      _isConnected = true;
      if (_userId != null) {
        await _hubConnection!.invoke("JoinRoom", args: [_userId]);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('SignalR Error: $e');
      _isConnected = false;
    }
    */
    debugPrint('⚠️ SignalR temporarily disabled due to package issues');
  }
  
  void _handleNewNotification(List<dynamic>? args) {
    if (args != null && args.isNotEmpty) {
      final message = args[0] as String;
      
      if (args.length > 1 && args[1] is num) {
         final newBalance = (args[1] as num).toDouble();
         _balanceController.add(newBalance);
      }
      
      addLocalNotification('Thông báo mới', message, 'System');
    }
  }
  
  /// Lấy thông báo từ API
  Future<void> fetchNotifications() async {
    if (_userId == null) return;
    try {
      final response = await _api.get('${ApiConfig.notifications}/$_userId');
      if (response.statusCode == 200) {
        final data = response.data;
        _unreadCount = data['unreadCount'] ?? 0;
        final list = data['notifications'] as List? ?? [];
        _notifications.clear();
        _notifications.addAll(list.map((n) => NotificationItem.fromJson(n)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
    }
  }
  
  /// Thêm thông báo local
  void addLocalNotification(String title, String message, String type) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      type: type,
      createdDate: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }
  
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }
  
  void removeNotification(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    // _hubConnection?.stop();
    _balanceController.close();
    super.dispose();
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime createdDate;
  final bool isRead;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdDate,
    required this.isRead,
  });
  
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'System',
      createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
  
  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      createdDate: createdDate,
      isRead: isRead ?? this.isRead,
    );
  }
  
  String get iconName {
    switch (type) {
      case 'DepositApproved': return '💰';
      case 'BookingConfirmed': return '🎾';
      case 'TournamentResult': return '🏆';
      case 'NewNews': return '📰';
      default: return '🔔';
    }
  }
}
