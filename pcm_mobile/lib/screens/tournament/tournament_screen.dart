import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import 'tournament_detail_screen.dart';

/// Tournament Screen - Danh sách giải đấu

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _tournaments = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final res = await api.get(ApiConfig.tournaments);
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _tournaments = res.data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Load tournaments error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _filterByStatus(String status) {
    return _tournaments.where((t) {
      final s = t['status']?.toString().toLowerCase();
      switch (status) {
        case 'open':
          return s == 'open' || s == 'registering';
        case 'ongoing':
          return s == 'ongoing' || s == 'drawcompleted';
        case 'finished':
          return s == 'finished';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Đang mở'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTournamentList(_filterByStatus('open')),
                _buildTournamentList(_filterByStatus('ongoing')),
                _buildTournamentList(_filterByStatus('finished')),
              ],
            ),
    );
  }

  Widget _buildTournamentList(List<dynamic> tournaments) {
    if (tournaments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Chưa có giải đấu nào', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tournaments.length,
        itemBuilder: (context, index) => _buildTournamentCard(tournaments[index]),
      ),
    );
  }



  Widget _buildTournamentCard(dynamic tournament) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final current = tournament['currentParticipants'] ?? 0;
    final max = tournament['maxParticipants'] ?? 1;
    final progress = current / max;
    final status = tournament['status']?.toString().toLowerCase();
    
    // Status Logic
    String statusText;
    Color statusColor;
    if (status == 'open' || status == 'registering') {
      statusText = 'ĐĂNG KÝ NGAY';
      statusColor = AppColors.success;
    } else if (status == 'ongoing') {
      statusText = 'ĐANG DIỄN RA';
      statusColor = AppColors.warning;
    } else {
      statusText = 'KẾT THÚC';
      statusColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(tournament: tournament),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Image Placeholder or Gradient
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2C3E50),
                    const Color(0xFF4CA1AF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                ),
              child: Stack(
                children: [
                  // Placeholder Icon Background
                  Positioned.fill(
                    child: Center(
                      child: Icon(Icons.sports_tennis, size: 64, color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  Positioned(
                    top: 16, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament['name'] ?? 'Giải đấu',
                          style: AppTheme.heading2.copyWith(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
                        ),
                        Text(
                           '${DateFormat('dd/MM/yyyy').format(DateTime.parse(tournament['startDate'] ?? DateTime.now().toString()))}',
                           style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCompactInfo(Icons.people, '$current/$max HDL'),
                      _buildCompactInfo(Icons.attach_money, currencyFormat.format(tournament['entryFee'] ?? 0)),
                      _buildCompactInfo(Icons.emoji_events, currencyFormat.format(tournament['prizePool'] ?? 0)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceLight,
                      color: statusColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: AppTheme.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _joinTournament(dynamic tournament) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận tham gia'),
        content: Text(
          'Bạn có muốn đăng ký giải "${tournament['name']}"?\n\nPhí tham gia sẽ được trừ trực tiếp từ ví.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
      final res = await api.post(
        '${ApiConfig.tournaments}/join',
        data: {
          'tournamentId': tournament['id'],
          'memberId': auth.userId,
        },
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Chúc bạn thi đấu tốt!'),
              backgroundColor: AppColors.success,
            ),
          );
          auth.refreshProfile();
          _loadData();
        }
      } else {
        throw Exception(res.data.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }
}
