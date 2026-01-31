import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';

class CreateDuelScreen extends StatefulWidget {
  const CreateDuelScreen({super.key});

  @override
  State<CreateDuelScreen> createState() => _CreateDuelScreenState();
}

class _CreateDuelScreenState extends State<CreateDuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _betController = TextEditingController(text: '50000');
  final _messageController = TextEditingController();
  
  Map<String, dynamic>? _selectedOpponent;
  bool _isLoading = false;

  Future<void> _selectOpponent() async {
    final selected = await showSearch(
      context: context,
      delegate: OpponentSearchDelegate(),
    );

    if (selected != null) {
      setState(() => _selectedOpponent = selected);
    }
  }

  Future<void> _createDuel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOpponent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đối thủ')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final betAmount = double.tryParse(_betController.text) ?? 0;

    if (betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền cược phải lớn hơn 0')),
      );
      return;
    }

    if (auth.walletBalance < betAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số dư không đủ! Cần ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(betAmount)}')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final api = ApiService();

    try {
      final res = await api.post('/Duels', data: {
        'challengerId': auth.userId,
        'opponentId': _selectedOpponent!['id'],
        'betAmount': betAmount,
        'type': 0, // Singles (1v1)
        'message': _messageController.text.isNotEmpty ? _messageController.text : null,
      });

      if (res.statusCode == 200) {
        auth.refreshProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi lời thách đấu!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.data['message'] ?? 'Lỗi tạo thách đấu')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _betController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo thách đấu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số dư hiện tại:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormat.format(auth.walletBalance),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Opponent selector
              const Text('Đối thủ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectOpponent,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: _selectedOpponent?['avatarUrl'] != null
                            ? NetworkImage(_selectedOpponent!['avatarUrl'])
                            : null,
                        child: _selectedOpponent == null ? const Icon(Icons.person_add) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedOpponent?['fullName'] ?? 'Chọn đối thủ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedOpponent == null ? Colors.grey : Colors.black,
                              ),
                            ),
                            if (_selectedOpponent != null)
                              Text(
                                'DUPR: ${_selectedOpponent!['duprRating'] ?? 3.0}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bet amount
              const Text('Tiền cược (mỗi bên)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _betController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixText: 'đ',
                  helperText: 'Người thắng sẽ nhận được gấp đôi số tiền này',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message
              const Text('Lời nhắn (tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'VD: Dám chơi không? 😎',
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createDuel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GỬI LỜI THÁCH ĐẤU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpponentSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.length < 2) return const Center(child: Text('Nhập ít nhất 2 ký tự'));

    return FutureBuilder(
      future: ApiService().get(ApiConfig.members, queryParameters: {'search': query}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return const Center(child: Text('Lỗi tìm kiếm'));

        final List data = (snapshot.data?.data as List?) ?? [];
        final auth = context.read<AuthProvider>();
        final filtered = data.where((u) => u['id'] != auth.userId).toList();

        if (filtered.isEmpty) return const Center(child: Text('Không tìm thấy'));

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final user = filtered[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['avatarUrl'] != null ? NetworkImage(user['avatarUrl']) : null,
                child: user['avatarUrl'] == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user['fullName'] ?? 'Unknown'),
              subtitle: Text('DUPR: ${user['duprRating'] ?? 3.0}'),
              onTap: () => close(context, user),
            );
          },
        );
      },
    );
  }
}
