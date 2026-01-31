import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool _isLoading = true;
  List<dynamic> _bookings = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      // Format date for query
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await api.get('${ApiConfig.bookings}?from=$dateStr&to=$dateStr', useCache: false);
      
      if (res.statusCode == 200) {
        setState(() {
          _bookings = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Đặt sân', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueAccent.withOpacity(0.1),
            child: Row(
              children: [
                Text(
                  'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text('${_bookings.length} lượt đặt', style: GoogleFonts.outfit(color: Colors.blueAccent)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                ? const Center(child: Text('Không có lịch đặt sân nào ngày này'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final item = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sports_tennis, color: Colors.blue),
                          ),
                          title: Text(item['memberName'] ?? 'Unknown Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item['courtName']} | ${item['startTime'].toString().substring(0,5)} - ${item['endTime'].toString().substring(0,5)}'),
                              Text(currencyFormat.format(item['totalPrice']), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item['status'] == 2 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['status'] == 2 ? 'Cancelled' : 'Confirmed',
                              style: TextStyle(fontSize: 10, color: item['status'] == 2 ? Colors.red : Colors.green),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
