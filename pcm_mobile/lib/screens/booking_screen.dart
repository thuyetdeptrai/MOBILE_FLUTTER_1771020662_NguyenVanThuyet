import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final dynamic court;
  final String memberId;

  const BookingScreen({super.key, required this.court, required this.memberId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Mode: false = Đặt lẻ, true = Đặt định kỳ
  bool isRecurring = false;
  bool isLoading = false;

  // Dữ liệu chung
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 0);

  // Dữ liệu Đặt lẻ
  DateTime singleDate = DateTime.now();

  // Dữ liệu Đặt định kỳ
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(
    const Duration(days: 30),
  ); // Mặc định 1 tháng
  List<int> selectedDays = []; // 0=CN, 1=T2...

  // Hàm chọn Ngày (Dùng chung)
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isRecurring ? (isFromDate ? fromDate : toDate) : singleDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isRecurring) {
          if (isFromDate)
            fromDate = picked;
          else
            toDate = picked;
        } else {
          singleDate = picked;
        }
      });
    }
  }

  // Hàm chọn Giờ
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startTime = picked;
        else
          endTime = picked;
      });
    }
  }

  // Gửi API
  Future<void> _submitBooking() async {
    // Validate cơ bản
    final startDouble = startTime.hour + startTime.minute / 60.0;
    final endDouble = endTime.hour + endTime.minute / 60.0;
    if (endDouble <= startDouble) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giờ kết thúc phải sau giờ bắt đầu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isRecurring && selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 thứ trong tuần!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(singleDate);
      final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
      final toStr = DateFormat('yyyy-MM-dd').format(toDate);

      // Tạo 2 cái DateTime giả để lấy giờ gửi lên (Backend chỉ lấy giờ)
      final sTime = DateTime.parse(
        '$dateStr ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
      );
      final eTime = DateTime.parse(
        '$dateStr ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
      );

      http.Response response;

      if (!isRecurring) {
        // --- GỌI API ĐẶT LẺ (CŨ) ---
        final url = Uri.parse('http://localhost:5176/api/Bookings');
        response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'courtId': widget.court['id'],
            'memberId': widget.memberId,
            'startTime': sTime.toIso8601String(),
            'endTime': eTime.toIso8601String(),
          }),
        );
      } else {
        // --- GỌI API ĐẶT ĐỊNH KỲ (MỚI) ---
        final url = Uri.parse('http://localhost:5176/api/Bookings/recurring');
        response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'courtId': widget.court['id'],
            'memberId': widget.memberId,
            'startTime': sTime.toIso8601String(),
            'endTime': eTime.toIso8601String(),
            'fromDate': fromStr,
            'toDate': toStr,
            'daysOfWeek': selectedDays,
          }),
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.court['name']),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CÔNG TẮC CHUYỂN CHẾ ĐỘ ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Đặt lịch cố định (Định kỳ)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: isRecurring,
                    onChanged: (val) {
                      setState(() => isRecurring = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- CHỌN NGÀY ---
            if (!isRecurring) ...[
              // Giao diện Đặt lẻ
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Ngày chơi"),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(singleDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _selectDate(context, true),
              ),
            ] else ...[
              // Giao diện Đặt định kỳ (Từ ngày - Đến ngày)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Từ ngày"),
                      subtitle: Text(
                        DateFormat('dd/MM').format(fromDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Đến ngày"),
                      subtitle: Text(
                        DateFormat('dd/MM').format(toDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Thứ trong tuần:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Chọn thứ (Chips)
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  // index 0 = CN (trong C#), nhưng hiển thị ta muốn T2, T3... CN
                  // Mapping: UI hiển thị -> Giá trị gửi đi (C# DayOfWeek: 0=Sun, 1=Mon...)
                  // Ta làm đơn giản: UI hiện CN, 2, 3... 7
                  final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                  final isSelected = selectedDays.contains(index);
                  return FilterChip(
                    label: Text(dayNames[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDays.add(index);
                        } else {
                          selectedDays.remove(index);
                        }
                      });
                    },
                    selectedColor: Colors.blue[200],
                  );
                }),
              ),
            ],
            const Divider(height: 30),

            // --- CHỌN GIỜ (DÙNG CHUNG) ---
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bắt đầu'),
                    subtitle: Text(
                      startTime.format(context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kết thúc'),
                    subtitle: Text(
                      endTime.format(context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- NÚT XÁC NHẬN ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isRecurring ? 'ĐẶT LỊCH ĐỊNH KỲ' : 'XÁC NHẬN ĐẶT SÂN',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
