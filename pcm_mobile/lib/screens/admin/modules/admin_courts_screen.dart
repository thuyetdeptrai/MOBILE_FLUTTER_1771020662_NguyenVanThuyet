import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AdminCourtsScreen extends StatefulWidget {
  const AdminCourtsScreen({super.key});

  @override
  State<AdminCourtsScreen> createState() => _AdminCourtsScreenState();
}

class _AdminCourtsScreenState extends State<AdminCourtsScreen> {
  bool _isLoading = true;
  List<dynamic> _courts = [];

  @override
  void initState() {
    super.initState();
    _fetchCourts();
  }

  Future<void> _fetchCourts() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final res = await api.get(ApiConfig.courts, useCache: false);
      if (res.statusCode == 200) {
        setState(() {
          _courts = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCourt(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Bạn có chắc chắn muốn xóa sân này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ApiService();
        await api.delete('${ApiConfig.courts}/$id');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sân thành công')));
        _fetchCourts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
      }
    }
  }

  void _showCourtDialog({Map<String, dynamic>? court}) {
    final nameController = TextEditingController(text: court?['name']);
    final typeController = TextEditingController(text: court?['type'] ?? 'Standard');
    final priceController = TextEditingController(text: court != null ? court['pricePerHour'].toString() : '100000');
    final imageController = TextEditingController(text: court?['imageUrl']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(court == null ? 'Thêm sân mới' : 'Cập nhật sân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên sân')),
              const SizedBox(height: 12),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Loại sân (Standard/Premium)')),
              const SizedBox(height: 12),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá thuê (VNĐ/h)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'URL Ảnh')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final api = ApiService();
              final data = {
                'name': nameController.text,
                'type': typeController.text,
                'pricePerHour': double.tryParse(priceController.text) ?? 0,
                'imageUrl': imageController.text,
              };

              try {
                if (court == null) {
                  // Create
                  await api.post(ApiConfig.courts, data: data);
                } else {
                  // Update
                  await api.put('${ApiConfig.courts}/${court['id']}', data: data);
                }
                Navigator.pop(ctx);
                _fetchCourts();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(court == null ? 'Thêm thành công' : 'Cập nhật thành công')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Sân bãi', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourtDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _courts.length,
            itemBuilder: (context, index) {
              final court = _courts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: court['imageUrl'] != null && court['imageUrl'].isNotEmpty
                      ? Image.network(court['imageUrl'], width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.sports_tennis, size: 40))
                      : const Icon(Icons.sports_tennis, size: 40, color: Colors.blue),
                  ),
                  title: Text(court['name'] ?? 'Sân', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${court['type']} - ${currencyFormat.format(court['pricePerHour'])}/h'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showCourtDialog(court: court)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCourt(court['id'])),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
