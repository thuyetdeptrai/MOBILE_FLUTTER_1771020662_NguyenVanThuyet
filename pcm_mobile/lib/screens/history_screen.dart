import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String? memberId; // Optional, if null use current user
  const HistoryScreen({super.key, this.memberId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final api = ApiService();
    // Default to current user if memberId not provided
    // Note: Ideally use context.read<AuthProvider>().userId but we can access it here or pass it in.
    // For now, let's assume the API might have an endpoint for 'my-bookings' without ID or we pass it.
    // Since argument is optional, we check logic.
    
    // However, to keep it simple and consistent with previous file:
    // If we passed memberId, use it. 
    try {
      // Use the standard bookings endpoint with filter? Or the specific endpoint?
      // Based on previous file: /api/Bookings/my-bookings/{id}
      // Let's stick to standard pattern if possible, or use the existing path if confirmed.
      // Given previous file used /my-bookings/, let's assume it exists or use filtering.
      
      // Let's try standard filtering first as it's safer given 404s earlier.
      // GET /api/Bookings?memberId=...
      final res = await api.get(
        ApiConfig.bookings, 
        queryParameters: {
           'memberId': widget.memberId ?? '', 
        }
      );

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            bookings = res.data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đặt sân'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("Bạn chưa có lịch sử đặt sân nào.", style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final item = bookings[index];
                    
                    // Safe date parsing - handle both DateTime and time-only formats
                    DateTime? start;
                    DateTime? end;
                    try {
                      final startStr = item['startTime']?.toString() ?? '';
                      final endStr = item['endTime']?.toString() ?? '';
                      
                      // Check if it's a full DateTime or just time
                      if (startStr.contains('T') || startStr.contains('-')) {
                        start = DateTime.tryParse(startStr);
                        end = DateTime.tryParse(endStr);
                      } else {
                        // It's just time like "08:00:00", use booking date
                        final bookingDate = DateTime.tryParse(item['bookingDate']?.toString() ?? '') ?? DateTime.now();
                        final startParts = startStr.split(':');
                        final endParts = endStr.split(':');
                        if (startParts.length >= 2 && endParts.length >= 2) {
                          start = DateTime(bookingDate.year, bookingDate.month, bookingDate.day, 
                            int.tryParse(startParts[0]) ?? 0, int.tryParse(startParts[1]) ?? 0);
                          end = DateTime(bookingDate.year, bookingDate.month, bookingDate.day,
                            int.tryParse(endParts[0]) ?? 0, int.tryParse(endParts[1]) ?? 0);
                        }
                      }
                    } catch (e) {
                      debugPrint('Date parse error: $e');
                    }
                    
                    start ??= DateTime.now();
                    end ??= DateTime.now();
                    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sports_tennis, color: AppColors.primary),
                        ),
                        title: Text(item['courtName'] ?? 'Sân không tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(DateFormat('dd/MM/yyyy').format(start), style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                priceFormat.format(item['totalPrice']),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        trailing: _buildStatusChip(item['status']),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(int status) {
     Color color;
     String text;
     if (status == 1) { // Confirmed/Paid
       color = AppColors.success;
       text = 'Thành công';
     } else if (status == 2) { // Cancelled
       color = AppColors.error;
       text = 'Đã hủy';
     } else { // Pending
       color = AppColors.warning;
       text = 'Chờ xử lý';
     }

     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: color),
       ),
       child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
     );
  }
}