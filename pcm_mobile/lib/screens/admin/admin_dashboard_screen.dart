import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../core/theme/app_theme.dart';
import 'modules/admin_users_screen.dart';
import 'modules/admin_finance_screen.dart';
import 'modules/admin_courts_screen.dart';
import 'modules/admin_tournaments_screen.dart';
import 'modules/admin_bookings_screen.dart';
import 'modules/admin_matches_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<dynamic>? _chartData;
  Map<String, dynamic> _stats = {
    'revenue': 0,
    'members': 0,
    'bookings': 0
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      // Fetch chart data
      final chartRes = await api.get('/Analytics/revenue-chart', useCache: false);
      // Fetch overview data (nếu có endpoint, tạm thời giả lập hoặc lấy từ chart)
      
      if (mounted) {
        setState(() {
          _chartData = chartRes.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildChartSection(),
                      const SizedBox(height: 24),
                      _buildMenuGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Quan trọng để tránh lỗi overflow
          children: [
            Text(
              'Admin Dashboard',
              style: GoogleFonts.outfit(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
             Text(
              'Quản lý hệ thống PCM',
              style: GoogleFonts.outfit(
                fontSize: 10, 
                fontWeight: FontWeight.normal,
                color: Colors.white70
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doanh thu', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('6 tháng gần nhất', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bar_chart, color: AppColors.primary),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildSimpleChart()),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
     if (_chartData == null || _chartData!.isEmpty) return const Center(child: Text("No Data"));
     
     return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _chartData!.map((e) => (e['amount'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 return BarTooltipItem(
                   NumberFormat.compact(locale: 'vi').format(rod.toY),
                   GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                 );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                   final index = value.toInt();
                   if (index >= 0 && index < _chartData!.length) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8),
                       child: Text(
                         _chartData![index]['month'], 
                         style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)
                       ),
                     );
                   }
                   return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _chartData!.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['amount'] as num).toDouble(),
                  gradient: AppColors.primaryGradient,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: _chartData!.map((e) => (e['amount'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                    color: AppColors.surfaceLight,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildGridItem('Thành viên', Icons.group, Colors.orangeAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
        }),
        _buildGridItem('Tài chính', Icons.attach_money, Colors.green, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceScreen()));
        }),
        _buildGridItem('Sân bãi', Icons.sports_tennis, Colors.blue, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCourtsScreen()));
        }),
        _buildGridItem('Lịch đặt', Icons.calendar_month, Colors.teal, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen()));
        }),
        _buildGridItem('Kèo đấu', Icons.sports_handball, Colors.deepPurple, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMatchesScreen()));
        }),
        _buildGridItem('Giải đấu', Icons.emoji_events, Colors.amber, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTournamentsScreen()));
        }),
      ],
    );
  }

  Widget _buildGridItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title, 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
