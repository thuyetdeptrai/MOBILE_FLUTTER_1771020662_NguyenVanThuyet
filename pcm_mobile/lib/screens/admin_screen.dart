import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> tournaments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTournaments();
  }

  // Lấy danh sách giải đấu
  Future<void> fetchTournaments() async {
    final url = Uri.parse(
      'http://localhost:5176/api/Tournaments',
    ); // Nhớ đổi localhost nếu cần
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tournaments = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  // Hàm tạo giải đấu nhanh (Demo)
  Future<void> _createQuickTournament() async {
    final url = Uri.parse('http://localhost:5176/api/Tournaments');

    // Dữ liệu giải đấu mẫu
    final newTournament = {
      "name": "Giải Mùa Hè ${DateTime.now().second}", // Tên ngẫu nhiên
      "description": "Giải đấu giao hữu cực căng",
      "startDate": DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
      "entryFee": 150000,
      "prizePool": 3000000,
      "maxParticipants": 8,
      "status": "Open",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newTournament),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã tạo giải mới thành công!")),
        );
        fetchTournaments(); // Load lại danh sách
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi khi tạo giải!")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN TRỊ VIÊN (ADMIN)'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Thống Kê (Dashboard)
            const Text(
              "Tổng quan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard("Doanh thu", "15.000.000đ", Colors.green),
                const SizedBox(width: 10),
                _buildStatCard("Thành viên", "124", Colors.blue),
                const SizedBox(width: 10),
                _buildStatCard("Sân đang đặt", "05", Colors.orange),
              ],
            ),

            const SizedBox(height: 30),

            // 2. Phần Quản lý Giải đấu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quản lý Giải Đấu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _createQuickTournament,
                  icon: const Icon(Icons.add),
                  label: const Text("Tạo Giải Nhanh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Danh sách giải đấu
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      final item = tournaments[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 40,
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Phí: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item['entryFee'])} | Đã ĐK: ${item['currentParticipants']}/${item['maxParticipants']}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Xử lý xóa sau (nếu cần)
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
