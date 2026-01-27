import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'booking_screen.dart';
import 'history_screen.dart';
import 'wallet_screen.dart';
import 'login_screen.dart';
import 'tournament_screen.dart';
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
