/// User Model - Đại diện cho thành viên CLB

class User {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String tier;        // Bronze, Silver, Gold, Diamond
  final double walletBalance;
  final double totalSpent;
  final double rankLevel;   // DUPR Rank (deprecated, use duprRating)
  final String role;        // User, Admin, Treasurer, Referee
  final DateTime joinDate;
  final bool isActive;
  
  // Thống kê người chơi - DỮ LIỆU THỰC
  final double duprRating;    // DUPR từ 2.0 - 6.0
  final int totalMatches;     // Tổng số trận đã đấu
  final int matchesWon;       // Số trận thắng
  final int totalTournaments; // Số giải đã tham gia
  
  User({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.tier = 'Bronze',
    this.walletBalance = 0,
    this.totalSpent = 0,
    this.rankLevel = 3.0,
    this.role = 'User',
    DateTime? joinDate,
    this.isActive = true,
    this.duprRating = 3.0,
    this.totalMatches = 0,
    this.matchesWon = 0,
    this.totalTournaments = 0,
  }) : joinDate = joinDate ?? DateTime.now();
  
  // Computed property - Tỉ lệ thắng
  double get winRate => totalMatches > 0 ? (matchesWon / totalMatches) * 100 : 0;
  
  factory User.fromJson(Map<String, dynamic> json) {
    // Safe parsing helpers
    double safeDouble(dynamic value, double defaultVal) {
      if (value == null) return defaultVal;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? defaultVal;
    }
    int safeInt(dynamic value, int defaultVal) {
      if (value == null) return defaultVal;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultVal;
    }
    
    return User(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      tier: json['tier']?.toString() ?? 'Bronze',
      walletBalance: safeDouble(json['walletBalance'], 0),
      totalSpent: safeDouble(json['totalSpent'], 0),
      rankLevel: safeDouble(json['rankLevel'], 3.0),
      role: json['role']?.toString() ?? 'User',
      joinDate: json['joinDate'] != null 
          ? DateTime.tryParse(json['joinDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] == true,
      // Thống kê thực - với default values
      duprRating: safeDouble(json['duprRating'], 3.0),
      totalMatches: safeInt(json['totalMatches'], 0),
      matchesWon: safeInt(json['matchesWon'], 0),
      totalTournaments: safeInt(json['totalTournaments'], 0),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'tier': tier,
      'walletBalance': walletBalance,
      'totalSpent': totalSpent,
      'rankLevel': rankLevel,
      'role': role,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'duprRating': duprRating,
      'totalMatches': totalMatches,
      'matchesWon': matchesWon,
      'totalTournaments': totalTournaments,
    };
  }
  
  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? tier,
    double? walletBalance,
    double? totalSpent,
    double? rankLevel,
    String? role,
    DateTime? joinDate,
    bool? isActive,
    double? duprRating,
    int? totalMatches,
    int? matchesWon,
    int? totalTournaments,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tier: tier ?? this.tier,
      walletBalance: walletBalance ?? this.walletBalance,
      totalSpent: totalSpent ?? this.totalSpent,
      rankLevel: rankLevel ?? this.rankLevel,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      duprRating: duprRating ?? this.duprRating,
      totalMatches: totalMatches ?? this.totalMatches,
      matchesWon: matchesWon ?? this.matchesWon,
      totalTournaments: totalTournaments ?? this.totalTournaments,
    );
  }
  
  bool get isAdmin => role == 'Admin';
  bool get isTreasurer => role == 'Treasurer';
  bool get isReferee => role == 'Referee';
  bool get isVip => tier == 'Gold' || tier == 'Diamond';
}
