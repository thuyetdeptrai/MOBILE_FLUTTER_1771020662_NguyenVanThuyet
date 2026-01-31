import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../create_tournament_screen.dart';

class AdminTournamentsScreen extends StatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  State<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends State<AdminTournamentsScreen> {
  bool _isLoading = true;
  List<dynamic> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final res = await api.get(ApiConfig.tournaments, useCache: false);
      if (res.statusCode == 200) {
        setState(() {
          _tournaments = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createTournament() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTournamentScreen()),
    );
    
    if (result == true) {
      _fetchTournaments();
    }
  }

  Future<void> _generateSchedule(dynamic tournament) async {
    final api = ApiService();
    try {
      await api.post('${ApiConfig.tournaments}/${tournament['id']}/generate-schedule');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo lịch đấu!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Giải đấu', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTournament,
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tournaments.length,
            itemBuilder: (context, index) {
              final t = _tournaments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                  title: Text(t['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${t['currentParticipants'] ?? 0}/${t['maxParticipants'] ?? 0} người tham gia'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'schedule', child: Text('Tạo lịch đấu')),
                      const PopupMenuItem(value: 'result', child: Text('Nhập kết quả')),
                    ],
                    onSelected: (val) {
                      if (val == 'schedule') _generateSchedule(t);
                       // Result logic omitted for brevity
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}
