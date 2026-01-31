import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/core.dart';

import 'widgets/news_banner.dart';
import '../booking/booking_calendar_screen.dart';
import '../tournament/tournament_screen.dart';
import '../history_screen.dart';
import '../duel/duels_screen.dart';
import '../matches/matches_screen.dart';

/// Home Screen - Dashboard chính với thống kê và danh sách sân

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> courts = [];
  List<dynamic> upcomingBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final courtsResponse = await api.get(ApiConfig.courts);
      if (courtsResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            courts = courtsResponse.data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Load courts error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Unified Header (User Info + Wallet)
          _buildHeader(),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Actions (New)
                _buildQuickActions(),
                
                // Upcoming Match (New)
                _buildUpcomingMatch(),

                // Leaderboard (DUPR Chart)
                _buildDUPRChart(),
                const SizedBox(height: 24),

                // Stats Row
                _buildStatsRow(),
                const SizedBox(height: 32),

                // News Section
                _buildSectionHeader('Tin tức & Sự kiện', Icons.newspaper),
                const SizedBox(height: 16),
                const NewsBanner(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background (Compact header)
          Container(
            height: 90, 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D9488), // Teal 600
                  const Color(0xFF059669), // Emerald 600
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // User Info Row
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar (smaller)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: auth.currentUser?.avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(auth.currentUser!.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: auth.currentUser?.avatarUrl == null
                                ? const Icon(Icons.person, color: Colors.white, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          
                          // Name & Tier (compact)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  auth.currentUser?.fullName ?? 'Vợt thủ',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Tier Badge (Gold/Diamond)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white30, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars, color: auth.tier.tierColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        auth.tier.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, 
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Wallet Balance Display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  NumberFormat.currency(locale: 'vi', symbol: 'đ', decimalDigits: 0).format(auth.walletBalance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartWalletCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          transform: Matrix4.translationValues(0, -40, 0), // Floating effect
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.walletGradient, // Defined in theme
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Text('Số dư khả dụng', style: AppTheme.bodyMedium.copyWith(color: Colors.white70)),
                          ],
                        ),
                        // Quick Deposit Button (Mini)
                        InkWell(
                          onTap: _showDepositDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, size: 16, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text('Nạp nhanh', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          currencyFormat.format(auth.walletBalance),
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 24), 
      transform: Matrix4.translationValues(0, -20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Center items
        children: [
          _buildQuickActionItem(Icons.calendar_month, 'Đặt sân', AppColors.primary, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingCalendarScreen()));
          }),
          _buildQuickActionItem(Icons.emoji_events, 'Giải đấu', AppColors.warning, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentScreen()));
          }),
          _buildQuickActionItem(Icons.sports_tennis, 'Trận đấu', AppColors.accent, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => MatchesScreen()));
          }),
          _buildQuickActionItem(Icons.sports_mma, 'Thách đấu', AppColors.error, () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const DuelsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 68, // Bigger icons
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.bold, 
              color: AppColors.textPrimary,
              fontSize: 14
            ),
          ),
        ],
      ),
    );
  }

  // Uses fl_chart
  Widget _buildDUPRChart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Phong độ DUPR', Icons.auto_graph),
            Text('30 ngày', style: AppTheme.caption.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LineChart(
             LineChartData(
               gridData: FlGridData(
                 show: true,
                 drawVerticalLine: false,
                 getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
               ),
               titlesData: FlTitlesData(
                 show: true,
                 rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                 bottomTitles: AxisTitles(
                   sideTitles: SideTitles(
                     showTitles: true,
                     getTitlesWidget: (value, meta) {
                       const style = TextStyle(color: Colors.grey, fontSize: 10);
                       switch (value.toInt()) {
                         case 0: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Tuần 1', style: style));
                         case 2: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Tuần 2', style: style));
                         case 4: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Tuần 3', style: style));
                         case 6: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Nay', style: style));
                       }
                       return const Text('');
                     },
                     interval: 1,
                   ),
                 ),
                 leftTitles: AxisTitles(
                   sideTitles: SideTitles(
                     showTitles: true,
                     interval: 0.5,
                     getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                     reservedSize: 30,
                   ),
                 ),
               ),
               borderData: FlBorderData(show: false),
               minX: 0, maxX: 6,
               minY: 2.0, maxY: 5.5,
               lineBarsData: [
                 LineChartBarData(
                   spots: const [
                     FlSpot(0, 3.2),
                     FlSpot(1, 3.4),
                     FlSpot(2, 3.3),
                     FlSpot(3, 3.8),
                     FlSpot(4, 3.9),
                     FlSpot(5, 4.1),
                     FlSpot(6, 4.2),
                   ],
                   isCurved: true,
                   color: AppColors.accent,
                   barWidth: 3,
                   isStrokeCapRound: true,
                   dotData: FlDotData(show: false),
                   belowBarData: BarAreaData(
                     show: true,
                     color: AppColors.accent.withOpacity(0.1),
                   ),
                 ),
               ],
             ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.heading2),
      ],
    );
  }

  Widget _buildUpcomingMatch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
           Row(
             children: [
               const Icon(Icons.timer, color: AppColors.primary),
               const SizedBox(width: 8),
               Text('Trận đấu sắp tới', style: AppTheme.heading3),
             ],
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                 child: const Icon(Icons.sports_tennis, color: AppColors.primary),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Sân 1 - Pickleball Phố Núi', style: TextStyle(fontWeight: FontWeight.bold)),
                     Text('18:00 - 20:00, Hôm nay', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                   ],
                 ),
               ),
               ElevatedButton(
                 onPressed: () {
                    // Navigate to Booking Screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingCalendarScreen()));
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
                 child: const Text('Chi tiết'),
               )
             ],
           )
        ],
      ),
    );
  }
  
  Widget _buildStatsRow() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final tournaments = user?.totalTournaments ?? 0;
        final wins = user?.matchesWon ?? 0;
        final winRate = user?.winRate ?? 0;
        
        return Row(
          children: [
            Expanded(child: _buildStatItem('$tournaments', 'Giải đấu', Icons.emoji_events, AppColors.warning)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('$wins', 'Trận thắng', Icons.thumb_up, AppColors.success)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('${winRate.toStringAsFixed(0)}%', 'Tỉ lệ thắng', Icons.pie_chart, AppColors.accent)),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    int currentStep = 1; 
    double depositAmount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentStep == 1 ? 'Nạp tiền vào ví' : 'Thanh toán QR',
                      style: AppTheme.heading2,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: currentStep == 1 
                    ? _buildDepositInputStep(amountController, () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount < 10000) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tối thiểu 10,000đ'), backgroundColor: AppColors.error),
                          );
                          return;
                        }
                        setStateDialog(() {
                          depositAmount = amount;
                          currentStep = 2;
                        });
                      })
                    : _buildDepositQRStep(depositAmount, () {
                        _submitDeposit(depositAmount);
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepositInputStep(TextEditingController controller, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập số tiền bạn muốn nạp',
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTheme.heading3.copyWith(color: AppColors.accent, fontSize: 32),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'đ',
            prefixIcon: const Icon(Icons.attach_money, color: AppColors.accent, size: 28),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        // Suggested amounts
        Wrap(
          spacing: 8,
          children: [50000, 100000, 200000, 500000].map((amount) {
            final formatted = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(amount);
            return ActionChip(
              label: Text(formatted),
              backgroundColor: AppColors.surfaceLight,
              onPressed: () => controller.text = amount.toStringAsFixed(0),
            );
          }).toList(),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('TIẾP TỤC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildDepositQRStep(double amount, VoidCallback onConfirm) {
    // VietQR URL
    final bankId = 'MB';
    final accountNo = '0336063462'; 
    final accountName = 'PCM PICKLEBALL';
    final content = 'NAP ${amount.toInt()}';
    final qrUrl = 'https://img.vietqr.io/image/$bankId-$accountNo-compact.png?amount=${amount.toInt()}&addInfo=$content&accountName=$accountName';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight),
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
              Text('Quét mã QR để thanh toán', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Image.network(
                qrUrl,
                height: 200,
                width: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200, 
                    child: Center(child: CircularProgressIndicator())
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(amount),
                style: AppTheme.heading1.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sau khi chuyển khoản thành công, vui lòng nhấn "Đã chuyển tiền" để hệ thống xử lý.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('ĐÃ CHUYỂN TIỀN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitDeposit(double amount) async {
    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
        final res = await api.post(
          '${ApiConfig.wallet}/deposit',
          data: {
            'memberId': auth.userId,
            'amount': amount,
            'evidenceUrl': 'QR_AUTO_PAY', 
          },
        );

        if (res.statusCode == 200) {
          if (mounted) {
            Navigator.pop(context); 
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Icon(Icons.check_circle, color: AppColors.success, size: 50),
                content: const Text(
                  'Yêu cầu nạp tiền đã được gửi thành công!\nVui lòng chờ Admin duyệt.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          }
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showMatchMatchingDialog() {
    double selectedDupr = 3.0;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_search, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text('Tìm kèo đấu'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trình độ (DUPR):', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(selectedDupr.toStringAsFixed(1), style: AppTheme.heading3.copyWith(color: AppColors.primary)),
                  Expanded(
                    child: Slider(
                      value: selectedDupr,
                      min: 2.0,
                      max: 5.0,
                      divisions: 30,
                      activeColor: AppColors.accent,
                      onChanged: (val) => setStateDialog(() => selectedDupr = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Thời gian rảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'Tối nay (18:00 - 20:00)',
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                dropdownColor: AppColors.surfaceLight,
                items: [
                  'Ngay bây giờ',
                  'Tối nay (18:00 - 20:00)',
                  'Sáng mai (6:00 - 8:00)',
                  'Cuối tuần này'
                ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                // Simulate loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 16),
                        Text('Đang tìm đối thủ phù hợp...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  ),
                );
                
                Future.delayed(const Duration(seconds: 3), () {
                   if (mounted) {
                     showDialog(
                       context: context,
                       builder: (_) => AlertDialog(
                         backgroundColor: AppColors.surface,
                         title: const Text('Kết quả'),
                         content: const Text('Hiện tại chưa có người chơi phù hợp trong khu vực.\nChúng tôi sẽ thông báo khi có kèo!'),
                         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                       ),
                     );
                   }
                });
              },
              icon: const Icon(Icons.search),
               label: const Text('Tìm Ngay'),
               style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
