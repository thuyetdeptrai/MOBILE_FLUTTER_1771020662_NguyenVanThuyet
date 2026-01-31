import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/models/match_model.dart'; // Though not directly used, for enums if needed
import '../../core/models/user_model.dart'; // For MatchPlayer mapping

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  int? _selectedCourtId;
  List<dynamic> _courts = [];
  bool _isLoading = false;
  
  // Players
  Map<String, dynamic>? _t1p1;
  Map<String, dynamic>? _t1p2;
  Map<String, dynamic>? _t2p1;
  Map<String, dynamic>? _t2p2;
  
  @override
  void initState() {
    super.initState();
    _loadCourts();
    // Default current user as T1P1
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _t1p1 = {
        'id': user.id,
        'fullName': user.fullName,
        'avatarUrl': user.avatarUrl,
        'duprRating': user.duprRating
      };
    }
  }

  Future<void> _loadCourts() async {
    final api = ApiService();
    try {
      final res = await api.get(ApiConfig.courts);
      if (res.statusCode == 200) {
        setState(() => _courts = res.data);
      }
    } catch (e) {
      debugPrint('Load courts error: $e');
    }
  }

  Future<void> _selectPlayer(int position) async {
    // position: 1=T1P1, 2=T1P2, 3=T2P1, 4=T2P2
    final selected = await showSearch(
      context: context,
      delegate: PlayerSearchDelegate(),
    );
    
    if (selected != null) {
      setState(() {
        if (position == 1) _t1p1 = selected;
        else if (position == 2) _t1p2 = selected;
        else if (position == 3) _t2p1 = selected;
        else if (position == 4) _t2p2 = selected;
      });
    }
  }

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_t1p1 == null || _t2p1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất 1 người mỗi đội')));
      return;
    }

    setState(() => _isLoading = true);
    final api = ApiService();
    
    final startTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    
    try {
      final res = await api.post(ApiConfig.matches, data: {
        'courtId': _selectedCourtId,
        'matchDate': _date.toIso8601String(),
        'startTime': DateFormat('HH:mm:ss').format(startTime),
        'team1Player1Id': _t1p1!['id'],
        'team1Player2Id': _t1p2?['id'],
        'team2Player1Id': _t2p1!['id'],
        'team2Player2Id': _t2p2?['id'],
        'type': 0, // Friendly
      });

      if (res.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo trận đấu thành công!')));
           Navigator.pop(context);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message'] ?? 'Lỗi tạo trận')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo trận đấu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thời gian & Địa điểm'),
              const SizedBox(height: 8),
              Row(
                children: [
                   Expanded(
                     child: InkWell(
                       onTap: () async {
                         final d = await showDatePicker(
                           context: context, 
                           initialDate: _date, 
                           firstDate: DateTime.now().subtract(const Duration(days: 7)),
                           lastDate: DateTime.now().add(const Duration(days: 30))
                         );
                         if (d != null) setState(() => _date = d);
                       },
                       child: InputDecorator(
                         decoration: const InputDecoration(labelText: 'Ngày', border: OutlineInputBorder()),
                         child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                       ),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: InkWell(
                       onTap: () async {
                         final t = await showTimePicker(context: context, initialTime: _time);
                         if (t != null) setState(() => _time = t);
                       },
                       child: InputDecorator(
                         decoration: const InputDecoration(labelText: 'Giờ', border: OutlineInputBorder()),
                         child: Text(_time.format(context)),
                       ),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCourtId,
                decoration: const InputDecoration(labelText: 'Sân', border: OutlineInputBorder()),
                items: [
                   const DropdownMenuItem<int>(value: null, child: Text('Sân ngoài / Khác')),
                   ..._courts.map((c) => DropdownMenuItem<int>(
                     value: c['id'],
                     child: Text(c['name']),
                   )),
                ],
                onChanged: (val) => setState(() => _selectedCourtId = val),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Đội 1'),
              const SizedBox(height: 8),
              _buildPlayerSelector(1, _t1p1, 'Người chơi 1 (Bạn)'),
              const SizedBox(height: 8),
              _buildPlayerSelector(2, _t1p2, 'Người chơi 2 (Tùy chọn)'),

              const SizedBox(height: 24),
              _buildSectionTitle('Đội 2'),
              const SizedBox(height: 8),
              _buildPlayerSelector(3, _t2p1, 'Người chơi 1'),
              const SizedBox(height: 8),
              _buildPlayerSelector(4, _t2p2, 'Người chơi 2 (Tùy chọn)'),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createMatch,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('TẠO TRẬN ĐẤU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary));
  }

  Widget _buildPlayerSelector(int pos, Map<String, dynamic>? player, String label) {
    return InkWell(
      onTap: () => _selectPlayer(pos),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: player?['avatarUrl'] != null ? NetworkImage(player!['avatarUrl']) : null,
              child: player == null || player['avatarUrl'] == null ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    player?['fullName'] ?? 'Chọn người chơi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: player == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (player != null) 
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                   setState(() {
                     if (pos == 1) _t1p1 = null;
                     else if (pos == 2) _t1p2 = null;
                     else if (pos == 3) _t2p1 = null;
                     else if (pos == 4) _t2p2 = null;
                   });
                },
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class PlayerSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
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
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }
  
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
        if (data.isEmpty) return const Center(child: Text('Không tìm thấy'));
        
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final user = data[index];
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
