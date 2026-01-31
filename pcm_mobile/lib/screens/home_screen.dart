import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/services/api_service.dart';
import '../core/config/api_config.dart';
import '../core/theme/app_theme.dart';
import 'booking_screen.dart';
import 'history_screen.dart';
import 'wallet_screen.dart';
import 'login_screen.dart';
import 'tournament_screen.dart';
import 'duel/duels_screen.dart'; // Import DuelsScreen

class HomeScreen extends StatefulWidget {
  final String fullName;
  final String userId;
  const HomeScreen({super.key, required this.fullName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> courts = [];
  bool isLoading = true;
  double walletBalance = 0;
  String currentTier = "Bronze";
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    fetchCourts();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await _api.get('${ApiConfig.wallet}/${widget.userId}', useCache: false);
      if (response.statusCode == 200) {
        final data = response.data;
        if (mounted) {
          setState(() {
            walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
            currentTier = data['tier'] ?? "Bronze";
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy số dư: $e");
    }
  }

  Future<void> fetchCourts() async {
    try {
      final response = await _api.get(ApiConfig.courts);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            courts = response.data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String getCourtImage(String? courtName) {
    if (courtName == null) return 'https://images.unsplash.com/photo-1626248316200-a51139785590?w=800&q=80';
    if (courtName.contains('VIP')) return 'https://images.unsplash.com/photo-1626248316200-a51139785590?w=800&q=80';
    if (courtName.contains('Sân 1')) return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80';
    return 'https://plus.unsplash.com/premium_photo-1677169829377-512c1fb67a21?w=800&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Dịch vụ chính'),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Danh sách sân'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildCourtCard(courts[index]);
                  },
                  childCount: courts.length,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true, // App bar ẩn hiện khi cuộn
      pinned: true,   // Giữ lại app bar khi cuộn hết
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text(
              widget.fullName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
              ),
              Text(
                widget.fullName,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: currentTier.tierColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: currentTier.tierColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.diamond, size: 14, color: currentTier.tierColor),
                const SizedBox(width: 4),
                Text(
                  currentTier.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: currentTier.tierColor // Màu chữ theo Tier
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white70),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng số dư',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(walletBalance),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen(userId: widget.userId)),
                    );
                    fetchBalance();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nạp tiền'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen(memberId: widget.userId)),
                    );
                  },
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Lịch sử'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.emoji_events,
          label: 'Giải đấu',
          color: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TournamentScreen(memberId: widget.userId)),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.sports_tennis, // Icon thay thế cho pickleball paddle
          label: 'Thách đấu',
          color: Colors.orange,
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DuelsScreen(memberId: widget.userId)),
            );
          },
        ),
         _buildActionButton(
          icon: Icons.notifications,
          label: 'Thông báo',
          color: Colors.blue,
          onTap: () {
            // TODO: Navigate to Notifications
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtCard(dynamic court) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  court: court,
                  memberId: widget.userId,
                ),
              ),
            );
            fetchBalance();
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      getCourtImage(court['name']),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.sports_tennis, size: 50, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ/h').format(court['pricePerHour']),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Khu A - Tầng 1', // Giả lập location
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  final String fullName;
  final String userId;
  const HomeScreen({super.key, required this.fullName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> courts = [];
  bool isLoading = true;
  double walletBalance = 0;
  String currentTier = "Bronze"; // <--- Biến lưu hạng

  @override
  void initState() {
    super.initState();
    fetchCourts();
    fetchBalance();
  }

  // Hàm lấy màu cho hạng
  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return Colors.purpleAccent;
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.blueGrey;
      default:
        return Colors.brown[300]!; // Bronze
    }
  }

  Future<void> fetchBalance() async {
    final url = Uri.parse('http://localhost:5176/api/Wallet/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
          currentTier = data['tier'] ?? "Bronze"; // <--- Lấy hạng từ API
        });
      }
    } catch (e) {
      print("Lỗi lấy số dư: $e");
    }
  }

  // (Giữ nguyên hàm getCourtImage và fetchCourts như cũ)
  String getCourtImage(String courtName) {
    if (courtName.contains('VIP'))
      return 'https://images.unsplash.com/photo-1626248316200-a51139785590?w=800&q=80';
    else if (courtName.contains('Sân 1'))
      return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80';
    else
      return 'https://plus.unsplash.com/premium_photo-1677169829377-512c1fb67a21?w=800&q=80';
  }

  Future<void> fetchCourts() async {
    final url = Uri.parse('http://localhost:5176/api/Courts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          courts = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PCM Pickleball', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(
                  'Chào, ${widget.fullName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // --- HUY HIỆU HẠNG ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTierColor(currentTier),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentTier.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(walletBalance),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.emoji_events,
              color: Colors.amber,
            ), // Icon Cúp vàng
            tooltip: 'Giải đấu',
            onPressed: () {
              // Chuyển sang màn hình giải đấu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TournamentScreen(memberId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletScreen(userId: widget.userId),
                ), // <--- SỬA THÀNH userId
              );
              fetchBalance();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(memberId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: courts.length,
              itemBuilder: (context, index) {
                final court = courts[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          getCourtImage(court['name']),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              court['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${court['pricePerHour']} đ/giờ',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingScreen(
                                        court: court,
                                        memberId: widget.userId,
                                      ),
                                    ),
                                  );
                                  fetchBalance();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Đặt ngay',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
