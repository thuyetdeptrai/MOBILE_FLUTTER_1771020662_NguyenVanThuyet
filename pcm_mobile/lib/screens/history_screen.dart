import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String memberId;
  const HistoryScreen({super.key, required this.memberId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    // Gọi API vừa viết
    final url = Uri.parse('http://localhost:5176/api/Bookings/my-bookings/${widget.memberId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          bookings = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt sân'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("Bạn chưa đặt sân nào!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final item = bookings[index];
                    final start = DateTime.parse(item['startTime']);
                    final end = DateTime.parse(item['endTime']);
                    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.blue, size: 36),
                        title: Text(item['courtName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat('dd/MM/yyyy').format(start)} | ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}'),
                            Text(
                              priceFormat.format(item['totalPrice']),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: item['status'] == 1
                            ? const Chip(label: Text('Thành công', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green)
                            : const Chip(label: Text('Đã hủy', style: TextStyle(color: Colors.white)), backgroundColor: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}