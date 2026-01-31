import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _pendingDeposits = [];
  Map<String, dynamic> _fundSummary = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    try {
      // 1. Pending Deposits
      final pendingRes = await api.get('${ApiConfig.wallet}/pending', useCache: false);
      if (pendingRes.statusCode == 200) {
        _pendingDeposits = pendingRes.data;
      }

      // 2. Fund Summary
      final fundRes = await api.get('${ApiConfig.wallet}/fund-summary', useCache: false);
      if (fundRes.statusCode == 200) {
        _fundSummary = fundRes.data;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveDeposit(int id) async {
    final api = ApiService();
    try {
      final res = await api.post('${ApiConfig.wallet}/approve/$id');
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt thành công!'), backgroundColor: Colors.green));
        _loadData(); // Reload
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.statusMessage ?? 'Lỗi khi duyệt'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Tài chính', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Duyệt nạp tiền'),
            Tab(text: 'Thống kê Quỹ'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildPendingList(),
              _buildFundStats(),
            ],
          ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingDeposits.isEmpty) {
      return const Center(child: Text('Không có yêu cầu nạp tiền nào chờ duyệt'));
    }
    
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingDeposits.length,
      itemBuilder: (context, index) {
        final item = _pendingDeposits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.orange, size: 40),
            title: Text(item['memberName'] ?? 'Unknown Member', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số tiền: ${currencyFormat.format(item['amount'])}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text(item['description'] ?? '', style: const TextStyle(fontSize: 12)),
                Text('Ngày: ${item['createdDate']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _approveDeposit(item['id']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFundStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatCard('Tổng nạp vào', _fundSummary['totalDeposited'], Colors.green),
          const SizedBox(height: 16),
          _buildStatCard('Tổng chi ra', _fundSummary['totalSpent'], Colors.red),
          const SizedBox(height: 16),
           _buildStatCard('Số dư quỹ hiện tại', _fundSummary['currentFund'], Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, Color color) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    double val = 0;
    if (value is int) val = value.toDouble();
    if (value is double) val = value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(currencyFormat.format(val), style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
