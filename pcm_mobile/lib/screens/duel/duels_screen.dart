import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import 'create_duel_screen.dart';
import 'duel_detail_screen.dart';

class DuelsScreen extends StatefulWidget {
  const DuelsScreen({super.key});

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendingDuels = [];
  List<dynamic> _activeDuels = [];
  List<dynamic> _completedDuels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final auth = context.read<AuthProvider>();

    try {
      final res = await api.get('/Duels', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        final List duels = res.data;
        _pendingDuels = duels.where((d) => d['status'] == 0).toList(); // Pending
        _activeDuels = duels.where((d) => d['status'] == 1 || d['status'] == 3).toList(); // Accepted/InProgress
        _completedDuels = duels.where((d) => d['status'] >= 4).toList(); // Completed/Cancelled
      }
    } catch (e) {
      debugPrint('Load duels error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kèo Thách đấu'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Lịch sử'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDuelList(_pendingDuels, isPending: true),
          _buildDuelList(_activeDuels),
          _buildDuelList(_completedDuels, isHistory: true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDuelScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.sports_mma, color: Colors.white),
        label: const Text('Thách đấu', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDuelList(List<dynamic> duels, {bool isPending = false, bool isHistory = false}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (duels.isEmpty) return const Center(child: Text('Chưa có kèo nào'));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: duels.length,
        itemBuilder: (context, index) {
          final duel = duels[index];
          return _buildDuelCard(duel, isPending: isPending, isHistory: isHistory);
        },
      ),
    );
  }

  Widget _buildDuelCard(dynamic duel, {bool isPending = false, bool isHistory = false}) {
    final auth = context.read<AuthProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    
    final challenger = duel['challenger'];
    final opponent = duel['opponent'];
    final isChallenger = challenger['id'] == auth.userId;
    final isOpponent = opponent['id'] == auth.userId;
    final status = duel['status'] as int;
    
    String statusText = '';
    Color statusColor = Colors.grey;
    
    switch (status) {
      case 0:
        statusText = isOpponent ? 'Chờ bạn chấp nhận' : 'Chờ đối thủ';
        statusColor = AppColors.warning;
        break;
      case 1:
        statusText = 'Đã chấp nhận';
        statusColor = AppColors.success;
        break;
      case 2:
        statusText = 'Từ chối';
        statusColor = AppColors.error;
        break;
      case 3:
        statusText = 'Đang thi đấu';
        statusColor = AppColors.primary;
        break;
      case 4:
        statusText = duel['winnerId'] == auth.userId ? 'Thắng' : 'Thua';
        statusColor = duel['winnerId'] == auth.userId ? AppColors.success : AppColors.error;
        break;
      case 5:
        statusText = 'Đã hủy';
        statusColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DuelDetailScreen(duelId: duel['id'])),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    currencyFormat.format(duel['betAmount'] ?? 0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerInfo(
                      challenger['fullName'],
                      challenger['avatarUrl'],
                      isChallenger ? '(Bạn)' : '',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: _buildPlayerInfo(
                      opponent['fullName'],
                      opponent['avatarUrl'],
                      isOpponent ? '(Bạn)' : '',
                      alignRight: true,
                    ),
                  ),
                ],
              ),
              if (isHistory && status == 4) ...[
                const Divider(height: 24),
                Center(
                  child: Text(
                    'Kết quả: ${duel['challengerScore']} - ${duel['opponentScore']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              if (isPending && isOpponent) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _declineDuel(duel['id']),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptDuel(duel['id']),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        child: const Text('Chấp nhận', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String name, String? avatarUrl, String suffix, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(height: 4),
        Text(
          '$name $suffix',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _acceptDuel(int duelId) async {
    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
      final res = await api.post('/Duels/$duelId/accept', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận thách đấu!'), backgroundColor: AppColors.success),
        );
        auth.refreshProfile();
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _declineDuel(int duelId) async {
    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
      final res = await api.post('/Duels/$duelId/decline', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối'), backgroundColor: Colors.grey),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
