import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      // Endpoint MembersController.GetMembers?search=...
      final res = await api.get('${ApiConfig.members}?search=$_searchQuery', useCache: false);
      if (res.statusCode == 200) {
        setState(() {
          _users = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Quản lý Thành viên', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tên, email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _fetchUsers();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (val) {
                setState(() => _searchQuery = val);
                _fetchUsers();
              },
            ),
          ),

          // User List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                ? const Center(child: Text('Không tìm thấy thành viên nào'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final tier = user['tier'] ?? 'Member';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            backgroundImage: user['avatarUrl'] != null 
                              ? NetworkImage(user['avatarUrl']) 
                              : null,
                            child: user['avatarUrl'] == null 
                              ? Text(user['fullName'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                              : null,
                          ),
                          title: Text(user['fullName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${user['userName']}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTierColor(tier).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _getTierColor(tier), width: 0.5),
                                ),
                                child: Text(tier, style: TextStyle(fontSize: 10, color: _getTierColor(tier), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            _showUserDetail(user);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'vip': return Colors.amber;
      case 'diamond': return Colors.blueAccent;
      case 'gold': return Colors.orange;
      case 'silver': return Colors.grey;
      default: return Colors.green;
    }
  }

  void _showUserDetail(dynamic user) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(user['fullName']),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Username: ${user['userName']}'),
             const SizedBox(height: 8),
             Text('ID: ${user['id']}'),
             const SizedBox(height: 8),
             Text('Rating: ${user['duprRating'] ?? 'N/A'}'),
           ],
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
         ],
       ),
     );
  }
}
