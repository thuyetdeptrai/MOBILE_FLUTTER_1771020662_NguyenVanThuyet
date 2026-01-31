import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/models/match_model.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  MatchModel? _match;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    try {
      final res = await api.get('${ApiConfig.matches}/${widget.matchId}');
      if (res.statusCode == 200) {
        setState(() => _match = MatchModel.fromJson(res.data));
      } else {
        _showError('Không tìm thấy trận đấu');
      }
    } catch (e) {
      _showError('Lỗi kết nối');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _showError(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showRecordResultDialog() async {
    final t1Ctrl = TextEditingController();
    final t2Ctrl = TextEditingController();
    
    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text('Ghi kết quả trận đấu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập điểm số cuối cùng'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: t1Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Đội 1', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('-')),
                Expanded(
                  child: TextField(
                    controller: t2Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Đội 2', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Lưu ý: Kết quả sẽ cập nhật DUPR ngay lập tức!', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final t1 = int.tryParse(t1Ctrl.text);
              final t2 = int.tryParse(t2Ctrl.text);
              if (t1 != null && t2 != null && t1 != t2) { // Draw not supported for now/DUPR logic usually needs winner?
                 Navigator.pop(context);
                 _submitResult(t1, t2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ (không hòa)')));
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      )
    );
  }

  Future<void> _submitResult(int t1, int t2) async {
    setState(() => _isProcessing = true);
    final api = ApiService();
    try {
      final res = await api.put('${ApiConfig.matches}/${widget.matchId}/result', data: {
        'team1Score': t1,
        'team2Score': t2
      });

      if (res.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật kết quả thành công!')));
           _loadMatch();
        }
      } else {
        _showError(res.data['message'] ?? 'Lỗi cập nhật');
      }
    } catch (e) {
      _showError('Lỗi kết nối');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_match == null) return const Scaffold(body: Center(child: Text('Trận đấu không tồn tại')));

    final m = _match!;
    final isCompleted = m.status == 2;
    final isCancelled = m.status == 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết trận đấu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success.withOpacity(0.1) : (isCancelled ? Colors.grey.withOpacity(0.1) : AppColors.warning.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : (isCancelled ? Icons.cancel : Icons.schedule),
                    color: isCompleted ? AppColors.success : (isCancelled ? Colors.grey : AppColors.warning),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted ? 'Đã kết thúc' : (isCancelled ? 'Đã hủy' : 'Sắp diễn ra / Đang đá'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.success : (isCancelled ? Colors.grey : AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Score Board
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildTeamColumn(m.team1Player1, m.team1Player2, 'Đội 1')),
                        Column(
                          children: [
                            Text(
                              isCompleted ? '${m.team1Score} - ${m.team2Score}' : 'VS',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            if (isCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                                child: Text('Winner: ${m.winner == 1 ? "Đội 1" : "Đội 2"}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Expanded(child: _buildTeamColumn(m.team2Player1, m.team2Player2, 'Đội 2')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info
            _buildInfoTile(Icons.calendar_today, 'Ngày', DateFormat('dd/MM/yyyy').format(m.matchDate)),
            _buildInfoTile(Icons.access_time, 'Giờ', m.startTime.substring(0, 5)), // "HH:mm"
            _buildInfoTile(Icons.stadium, 'Sân', m.courtName),
            
            const SizedBox(height: 32),
            
            // Actions
            if (!isCompleted && !isCancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _showRecordResultDialog,
                  icon: const Icon(Icons.sports_score),
                  label: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('GHI KẾT QUẢ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamColumn(MatchPlayer p1, MatchPlayer? p2, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        _buildPlayerAvatar(p1),
        const SizedBox(height: 4),
        Text(p1.fullName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text('DUPR: ${p1.duprRating}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        if (p2 != null) ...[
          const SizedBox(height: 12),
          _buildPlayerAvatar(p2),
          const SizedBox(height: 4),
          Text(p2.fullName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('DUPR: ${p2.duprRating}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]
      ],
    );
  }

  Widget _buildPlayerAvatar(MatchPlayer p) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
      child: p.avatarUrl == null ? const Icon(Icons.person) : null,
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
