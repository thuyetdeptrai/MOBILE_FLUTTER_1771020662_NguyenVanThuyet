import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';

class DuelDetailScreen extends StatefulWidget {
  final int duelId;

  const DuelDetailScreen({super.key, required this.duelId});

  @override
  State<DuelDetailScreen> createState() => _DuelDetailScreenState();
}

class _DuelDetailScreenState extends State<DuelDetailScreen> {
  Map<String, dynamic>? _duel;
  bool _isLoading = true;
  final _challengerScoreController = TextEditingController();
  final _opponentScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _challengerScoreController.dispose();
    _opponentScoreController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final res = await ApiService().get('/Duels/${widget.duelId}');
      if (res.statusCode == 200) {
        _duel = res.data;
      }
    } catch (e) {
      debugPrint('Load duel error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thách đấu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_duel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thách đấu')),
        body: const Center(child: Text('Không tìm thấy dữ liệu')),
      );
    }

    final auth = context.read<AuthProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final challenger = _duel!['challenger'];
    final opponent = _duel!['opponent'];
    final status = _duel!['status'] as int;
    final isChallenger = challenger['id'] == auth.userId;
    final isOpponent = opponent['id'] == auth.userId;
    final isInvolved = isChallenger || isOpponent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thách đấu'),
        actions: [
          if (status == 0 && isChallenger)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: _cancelDuel,
              tooltip: 'Hủy thách đấu',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Prize Pool
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('Tổng giải thưởng', style: TextStyle(color: Colors.white70)),
                          Text(
                            currencyFormat.format((_duel!['betAmount'] ?? 0) * 2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // VS Display
                    Row(
                      children: [
                        Expanded(child: _buildPlayerCard(challenger, isChallenger, 'Challenger')),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'VS',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        Expanded(child: _buildPlayerCard(opponent, isOpponent, 'Opponent')),
                      ],
                    ),

                    // Score (if completed)
                    if (status == 4) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_duel!['challengerScore']}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _duel!['winnerId'] == challenger['id'] ? AppColors.success : AppColors.error,
                              ),
                            ),
                            const Text(' - ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            Text(
                              '${_duel!['opponentScore']}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _duel!['winnerId'] == opponent['id'] ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_duel!['winnerId'] == auth.userId)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text('🎉 Bạn đã thắng!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status and actions
            _buildStatusWidget(status, isChallenger, isOpponent),

            // Message
            if (_duel!['message'] != null && _duel!['message'].toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lời nhắn:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(_duel!['message'], style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(dynamic player, bool isMe, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: player['avatarUrl'] != null ? NetworkImage(player['avatarUrl']) : null,
          child: player['avatarUrl'] == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 8),
        Text(
          player['fullName'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (isMe) const Text('(Bạn)', style: TextStyle(color: AppColors.primary, fontSize: 12)),
        Text('DUPR: ${player['duprRating'] ?? 3.0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusWidget(int status, bool isChallenger, bool isOpponent) {
    final auth = context.read<AuthProvider>();

    switch (status) {
      case 0: // Pending
        if (isOpponent) {
          return Column(
            children: [
              const Text(
                'Bạn có muốn chấp nhận thách đấu này không?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _declineDuel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('TỪ CHỐI'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptDuel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CHẤP NHẬN', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Đang chờ đối thủ chấp nhận...', style: TextStyle(color: AppColors.warning)),
            ],
          ),
        );

      case 1: // Accepted
      case 3: // InProgress
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Kèo đã được chấp nhận! Hãy thi đấu và ghi kết quả.', style: TextStyle(color: AppColors.success)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Ghi kết quả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _challengerScoreController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: _duel!['challenger']['fullName'],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('-', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: TextField(
                    controller: _opponentScoreController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: _duel!['opponent']['fullName'],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _recordResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('XÁC NHẬN KẾT QUẢ', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _acceptDuel() async {
    final auth = context.read<AuthProvider>();

    try {
      final res = await ApiService().post('/Duels/${widget.duelId}/accept', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        auth.refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận thách đấu!'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _declineDuel() async {
    final auth = context.read<AuthProvider>();

    try {
      final res = await ApiService().post('/Duels/${widget.duelId}/decline', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _cancelDuel() async {
    final auth = context.read<AuthProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy thách đấu?'),
        content: const Text('Tiền cược sẽ được hoàn lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hủy')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await ApiService().delete('/Duels/${widget.duelId}', queryParameters: {'memberId': auth.userId});
      if (res.statusCode == 200) {
        auth.refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy thách đấu')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _recordResult() async {
    final challengerScore = int.tryParse(_challengerScoreController.text) ?? 0;
    final opponentScore = int.tryParse(_opponentScoreController.text) ?? 0;

    if (challengerScore == opponentScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Điểm số không được bằng nhau!')),
      );
      return;
    }

    try {
      final res = await ApiService().put('/Duels/${widget.duelId}/result', data: {
        'challengerScore': challengerScore,
        'opponentScore': opponentScore,
      });

      if (res.statusCode == 200) {
        final auth = context.read<AuthProvider>();
        auth.refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã ghi kết quả!'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}
