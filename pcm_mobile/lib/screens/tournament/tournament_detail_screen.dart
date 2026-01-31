import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class TournamentDetailScreen extends StatefulWidget {
  final dynamic tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament['name'] ?? 'Chi tiết giải đấu'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Nhánh đấu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(context),
          _buildBracketTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final t = widget.tournament;
    final current = t['currentParticipants'] ?? 0;
    final max = t['maxParticipants'] ?? 1;
    final progress = current / max;
    final status = t['status']?.toString().toLowerCase();
    final isOpen = status == 'open' || status == 'registering';
    
    // Logic check balance
    final auth = context.read<AuthProvider>();
    final entryFee = (t['entryFee'] as num?)?.toDouble() ?? 0;
    final canAfford = auth.walletBalance >= entryFee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image (Placeholder)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.sports_tennis, size: 64, color: Colors.white.withOpacity(0.8)),
            ),
          ),
          const SizedBox(height: 24),

          // Title & Status
          Row(
            children: [
              Expanded(child: Text(t['name'] ?? '', style: AppTheme.heading2)),
              _buildStatusBadge(status ?? ''),
            ],
          ),
          const SizedBox(height: 16),

          // Details List
          _buildDetailItem(Icons.calendar_today, 'Ngày bắt đầu', t['startDate'] != null 
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(t['startDate'])) : 'Chưa cập nhật'),
          _buildDetailItem(Icons.location_on, 'Địa điểm', 'Sân Pickleball Phố Núi'),
          _buildDetailItem(Icons.people, 'Số lượng', '$current/$max vận động viên'),
          _buildDetailItem(Icons.attach_money, 'Phí tham gia', currencyFormat.format(entryFee)),
          _buildDetailItem(Icons.emoji_events, 'Tổng giải thưởng', currencyFormat.format(t['prizePool'] ?? 0)),
          
          const SizedBox(height: 32),
          
          // Action Button
          if (isOpen)
             Column(
               children: [
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: canAfford ? () async {
                         if (isOpen && t['isJoined'] != true) {
                             _joinTournament(context, t['id']);
                         }
                     } : null,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primary,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                     ),
                     child: Text(
                       canAfford 
                           ? (t['isJoined'] == true ? 'ĐÃ THAM GIA' : 'ĐĂNG KÝ THAM GIA') 
                           : 'KHÔNG ĐỦ SỐ DƯ'
                     ),
                   ),
                 ),
                 if (!canAfford)
                   Padding(
                     padding: const EdgeInsets.only(top: 8),
                     child: Text(
                       'Số dư hiện tại: ${currencyFormat.format(auth.walletBalance)}',
                       style: const TextStyle(color: AppColors.error),
                     ),
                   ),
               ],
             ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
     Color color;
     String text;
     
     if (status == 'open' || status == 'registering') {
       color = AppColors.success;
       text = 'ĐANG ĐĂNG KÝ';
     } else if (status == 'ongoing') {
       color = AppColors.warning;
       text = 'ĐANG DIỄN RA';
     } else {
       color = AppColors.textSecondary;
       text = 'KẾT THÚC';
     }
     
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: color),
       ),
       child: Text(
         text, 
         style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)
       ),
     );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Real Bracket View
  Widget _buildBracketTab() {
    final tournamentId = widget.tournament['id'];
    
    return FutureBuilder(
      future: ApiService().get('/Tournaments/$tournamentId/matches'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final matches = snapshot.data?.data as List? ?? [];

        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('Sơ đồ thi đấu', style: AppTheme.heading3),
                const SizedBox(height: 8),
                const Text(
                  'Sẽ được cập nhật khi giải đấu bắt đầu',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        // Group matches by round
        final Map<String, List<dynamic>> roundMatches = {};
        for (var match in matches) {
          final round = match['round'] ?? 'Unknown';
          roundMatches.putIfAbsent(round, () => []).add(match);
        }

        // Define round order for knockout
        final roundOrder = ['Round16', 'QuarterFinal', 'SemiFinal', 'Final'];
        final orderedRounds = roundMatches.keys.toList()
          ..sort((a, b) {
            final indexA = roundOrder.indexOf(a);
            final indexB = roundOrder.indexOf(b);
            if (indexA == -1 && indexB == -1) return a.compareTo(b);
            if (indexA == -1) return -1;
            if (indexB == -1) return 1;
            return indexA.compareTo(indexB);
          });

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: orderedRounds.map((round) {
                final roundMatchList = roundMatches[round] ?? [];
                return _buildRoundColumn(round, roundMatchList);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundColumn(String round, List<dynamic> matches) {
    String displayName = round;
    switch (round) {
      case 'Round16':
        displayName = 'Vòng 1/8';
        break;
      case 'QuarterFinal':
        displayName = 'Tứ kết';
        break;
      case 'SemiFinal':
        displayName = 'Bán kết';
        break;
      case 'Final':
        displayName = 'Chung kết';
        break;
    }

    // If round starts with "Group", it's a group stage
    if (round.startsWith('Group')) {
      displayName = 'Bảng ${round.replaceFirst('Group', '')}';
    }

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...matches.map((match) => _buildMatchCard(match)).toList(),
        ],
      ),
    );
  }

  Widget _buildMatchCard(dynamic match) {
    final status = match['status'] as int? ?? 0;
    final isCompleted = status == 3;

    final team1 = match['team1Player1'];
    final team2 = match['team2Player1'];

    Color borderColor = AppColors.surfaceLight;
    if (isCompleted) {
      borderColor = AppColors.success;
    } else if (status == 1) {
      borderColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTeamRow(team1, match['team1Score'] ?? 0, match['winner'] == 1),
          const Divider(height: 16),
          _buildTeamRow(team2, match['team2Score'] ?? 0, match['winner'] == 2),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('✓ Hoàn thành', style: TextStyle(color: AppColors.success, fontSize: 11)),
            ),
          if (status == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Chờ xác định', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(dynamic player, int score, bool isWinner) {
    final name = player?['fullName'] ?? 'TBD';
    final avatarUrl = player?['avatarUrl'];

    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person, size: 14) : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? AppColors.success : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isWinner ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? AppColors.success : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _joinTournament(BuildContext context, int tournamentId) async {
    final auth = context.read<AuthProvider>();
    final api = ApiService();
    
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await api.post('${ApiConfig.tournaments}/join', data: {
         'tournamentId': tournamentId,
         'memberId': auth.userId,
         'registeredDate': DateTime.now().toIso8601String(),
         'paymentStatus': 'Pending' 
      });
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        
        if (res.statusCode == 200) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: AppColors.success),
           );
           Navigator.pop(context, true); 
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Lỗi: ${res.data['message'] ?? 'Không thể đăng ký'}'), backgroundColor: AppColors.error),
           );
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        print('Error Data: ${e.response?.data}');
        
        String jsMessage = 'Lỗi kết nối';
        if (e.response != null && e.response!.data != null) {
           // Try to parse validation errors
           if (e.response!.data is Map) {
              final map = e.response!.data as Map;
              if (map['errors'] != null) {
                 jsMessage = map['errors'].toString();
              } else if (map['title'] != null) {
                 jsMessage = map['title'];
              }
           } else {
              jsMessage = e.response!.data.toString(); 
           }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi 400: $jsMessage'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
