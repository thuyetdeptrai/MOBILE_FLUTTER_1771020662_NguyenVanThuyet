import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _feeController = TextEditingController();
  final _prizeController = TextEditingController();
  final _participantsController = TextEditingController(text: '16');
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo giải đấu mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin giải đấu', style: AppTheme.heading3),
              const SizedBox(height: 16),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên giải đấu'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên giải' : null,
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả', alignLabelWithHint: true),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                ),
              ),
              const SizedBox(height: 24),
              
              Text('Cấu hình', style: AppTheme.heading3),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Phí tham gia (đ)'),
                      validator: (v) => v!.isEmpty ? 'Nhập phí' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tổng giải thưởng (đ)'),
                      validator: (v) => v!.isEmpty ? 'Nhập thưởng' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _participantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số lượng người tham gia tối đa'),
                validator: (v) => v!.isEmpty ? 'Nhập số lượng' : null,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('TẠO GIẢI ĐẤU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final api = ApiService();
    try {
      final res = await api.post(
        ApiConfig.tournaments,
        data: {
          'name': _nameController.text,
          'description': _descController.text,
          'startDate': _startDate.toIso8601String(),
          'entryFee': double.tryParse(_feeController.text) ?? 0,
          'prizePool': double.tryParse(_prizeController.text) ?? 0,
          'maxParticipants': int.tryParse(_participantsController.text) ?? 16,
          'status': 'Open',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo giải thành công!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context, true); // Return true to refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }
}
