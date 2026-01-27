import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TournamentScreen extends StatefulWidget {
  final String memberId;
  const TournamentScreen({super.key, required this.memberId});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  List<dynamic> tournaments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTournaments();
  }

  // 1. Hàm lấy danh sách giải đấu từ API
  Future<void> fetchTournaments() async {
    // Thử thay dòng này:
    final url = Uri.parse('http://127.0.0.1:5176/api/Tournaments');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tournaments = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Hàm xử lý Đăng ký tham gia
  Future<void> _joinTournament(int tournamentId, String tournamentName) async {
    // Hỏi xác nhận trước khi trừ tiền
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận tham gia"),
        content: Text(
          "Bạn có muốn đăng ký giải '$tournamentName' không?\nPhí tham gia sẽ được trừ trực tiếp vào ví.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Đồng ý",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    final url = Uri.parse('http://localhost:5176/api/Tournaments/join');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tournamentId': tournamentId,
          'memberId': widget.memberId,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng ký thành công! Chúc bạn thi đấu tốt!"),
              backgroundColor: Colors.green,
            ),
          );
          fetchTournaments(); // Tải lại danh sách để cập nhật số lượng người chơi
        }
      } else {
        if (mounted) {
          // Hiển thị lỗi từ Server (ví dụ: Không đủ tiền)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi: ${response.body}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi kết nối Server"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu chuyên nghiệp'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tournaments.isEmpty
          ? const Center(child: Text("Chưa có giải đấu nào."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final item = tournaments[index];
                final progress =
                    item['currentParticipants'] / item['maxParticipants'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Phần ảnh bìa giải đấu
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade100,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 50,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Phần thông tin chi tiết
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              "Phí tham gia:",
                              currencyFormat.format(item['entryFee']),
                              Colors.red,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              "Tổng giải thưởng:",
                              currencyFormat.format(item['prizePool']),
                              Colors.orange,
                            ),
                            const Divider(height: 24),

                            // Thanh tiến độ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Đã đăng ký: ${item['currentParticipants']}/${item['maxParticipants']}",
                                ),
                                Text("${(progress * 100).toInt()}%"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              color: Colors.blue,
                              backgroundColor: Colors.blue[100],
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 16),

                            // Nút bấm tham gia
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.sports_tennis),
                                label: const Text("THAM GIA NGAY"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _joinTournament(item['id'], item['name']),
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

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
