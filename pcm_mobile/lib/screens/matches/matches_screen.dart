import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../core/models/match_model.dart';
import 'create_match_screen.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MatchModel> _myMatches = [];
  List<MatchModel> _allMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final auth = context.read<AuthProvider>();
    
    try {
      // Load All Matches (Friendly)
      final allRes = await api.get(ApiConfig.matches, queryParameters: {'type': 0}); // 0: Friendly
      if (allRes.statusCode == 200) {
        _allMatches = (allRes.data as List).map((e) => MatchModel.fromJson(e)).toList();
      }

      // Load My Matches
      if (auth.userId != null) {
        final myRes = await api.get('${ApiConfig.matches}/my-matches/${auth.userId}');
        if (myRes.statusCode == 200) {
          _myMatches = (myRes.data as List).map((e) => MatchModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Load matches error: $e');
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trận đấu hằng ngày'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Của tôi'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(_allMatches),
          _buildMatchList(_myMatches),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMatchScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMatchList(List<MatchModel> matches) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (matches.isEmpty) return const Center(child: Text('Chưa có trận đấu nào'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final isCompleted = match.status == 2;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id)),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(match.matchDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCompleted ? 'Kết thúc' : 'Sắp diễn ra',
                      style: TextStyle(
                        color: isCompleted ? AppColors.success : AppColors.warning,
                        fontSize: 10, fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(child: _buildTeamInfo(match.team1Player1, match.team1Player2, isRight: false)),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 8),
                     child: Column(
                       children: [
                         Text(
                           isCompleted ? '${match.team1Score} - ${match.team2Score}' : 'VS',
                           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                         ),
                         Text(
                           match.courtName,
                           style: const TextStyle(fontSize: 10, color: Colors.grey),
                         ),
                       ],
                     ),
                   ),
                   Expanded(child: _buildTeamInfo(match.team2Player1, match.team2Player2, isRight: true)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(MatchPlayer p1, MatchPlayer? p2, {required bool isRight}) {
    // Simplify name display logic
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        _buildPlayerRow(p1, isRight),
        if (p2 != null) ...[
          const SizedBox(height: 4),
          _buildPlayerRow(p2, isRight),
        ],
      ],
    );
  }

  Widget _buildPlayerRow(MatchPlayer p, bool isRight) {
    final avatar = CircleAvatar(
      radius: 12,
      backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
      child: p.avatarUrl == null ? const Icon(Icons.person, size: 12) : null,
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isRight) ...[
          Flexible(child: Text(p.fullName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 4),
          avatar,
        ] else ...[
          avatar,
          const SizedBox(width: 4),
          Flexible(child: Text(p.fullName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ],
    );
  }
}
