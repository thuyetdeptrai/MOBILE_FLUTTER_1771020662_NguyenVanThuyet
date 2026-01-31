import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AdminMatchesScreen extends StatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  State<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends State<AdminMatchesScreen> {
  bool _isLoading = true;
  List<dynamic> _matches = [];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final res = await api.get(ApiConfig.matches, useCache: false);
      
      if (res.statusCode == 200) {
        setState(() {
          _matches = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Kèo đấu', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM HH:mm').format(DateTime.parse(match['matchDate'])),
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(match['courtName'] ?? 'Sân ngoài', style: GoogleFonts.outfit(fontSize: 10, color: Colors.deepPurple)),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(child: _buildTeamInfo(match['team1Player1'], match['team1Player2'], isWinner: match['winner'] == 1)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${match['team1Score']} - ${match['team2Score']}",
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(child: _buildTeamInfo(match['team2Player1'], match['team2Player2'], isWinner: match['winner'] == 2, isRight: true)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildTeamInfo(dynamic p1, dynamic p2, {bool isWinner = false, bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          p1['fullName'], 
          style: TextStyle(
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            color: isWinner ? Colors.green : Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (p2 != null) 
          Text(
            p2['fullName'],
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? Colors.green : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
