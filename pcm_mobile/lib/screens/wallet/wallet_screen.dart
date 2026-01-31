import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// TODO: Uncomment when signalr cache is repaired
// import 'package:signalr_netcore/signalr_netcore.dart';
import '../../core/core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Wallet Screen - Ví điện tử với SignalR real-time

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // All, Deposit, Spending

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
      // 1. Refresh Profile for Balance
      await auth.refreshProfile();

      // 2. Load Transactions
      final res = await api.get('${ApiConfig.wallet}/${auth.userId}');
      if (res.statusCode == 200) {
          if (mounted) {
            setState(() {
              final data = res.data;
              if (data is Map) {
                 _transactions = data['history'] ?? data['History'] ?? [];
              } else if (data is List) {
                 _transactions = data;
              } else {
                 _transactions = [];
              }
            });
          }
      }
    } catch (e) {
      debugPrint('Load wallet error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSmartWalletCard()),
                  SliverToBoxAdapter(child: _buildActionButtons()),
                  
                  // Filters
                  SliverToBoxAdapter(child: _buildFilterChips()),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text('Lịch sử giao dịch', style: AppTheme.heading3),
                    ),
                  ),
                  _buildTransactionsList(),
                ],
              ),
      ),
    );
  }

  // Use the new Smart Wallet Card from HomeScreen design
  Widget _buildSmartWalletCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
               colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Dark Blue to Blue
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Số dư khả dụng', style: AppTheme.bodyMedium.copyWith(color: Colors.white70)),
                   const Icon(Icons.account_balance_wallet, color: Colors.white54),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(auth.walletBalance),
                style: AppTheme.heading1.copyWith(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 16),
              // Tier info can go here if needed
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', 'All'),
          const SizedBox(width: 8),
          _buildFilterChip('Nạp tiền', 'Deposit'),
          const SizedBox(width: 8),
          _buildFilterChip('Chi tiêu', 'Spending'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.add_card, 'Nạp tiền', AppColors.success, _showDepositDialog),
          _buildActionButton(Icons.qr_code_scanner, 'QR Check-in', AppColors.primary, () {
             // Mock QR Check-in
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng QR Check-in đang phát triển')));
          }),
          _buildActionButton(Icons.history, 'Sao kê', AppColors.textSecondary, () {
             // TODO: Navigate to full history or export
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Filter logic
    final filtered = _transactions.where((t) {
       if (_selectedFilter == 'All') return true;
       
       // Improved Heuristic
       final type = t['type'] ?? '';
       final desc = t['description']?.toString().toLowerCase() ?? '';
       
       final isDeposit = type.toString().contains('Deposit') || 
                         desc.contains('nạp') ||
                         desc.contains('thưởng') ||
                         desc.contains('refund') ||
                         desc.contains('hoàn');

       if (_selectedFilter == 'Deposit') return isDeposit;
       if (_selectedFilter == 'Spending') return !isDeposit;
       
       return true;
    }).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Không có giao dịch nào', style: AppTheme.bodyMedium.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTransactionItem(filtered[index]),
        childCount: filtered.length,
      ),
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    final amount = (transaction['amount'] as num).toDouble();
    final description = transaction['description'] ?? 'Giao dịch';
    final type = transaction['type'] ?? ''; 
    final status = transaction['status'];
    final createdDate = transaction['createdDate'];
    
    // Strict Color Logic
    // Deposit/Reward/Refund = Green (+)
    // Payment/Withdraw = Red (-)
    final descLower = description.toString().toLowerCase();
    final isDeposit = type.toString().contains('Deposit') || 
                      descLower.contains('nạp') || 
                      descLower.contains('thưởng') || 
                      descLower.contains('hoàn');
                      
    final isPayment = !isDeposit;
    
    final isPending = status == 0 || status == 'Pending';
    final isFailed = status == 2 || status == 'Failed' || status == 'Cancelled';

    Color color;
    String prefix;

    if (isFailed) {
      color = Colors.grey;
      prefix = '';
    } else if (isDeposit) {
      color = AppColors.success;
      prefix = '+';
    } else {
      color = AppColors.error;
      prefix = '-';
    }
    
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      createdDate != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(createdDate))
                          : '',
                      style: AppTheme.caption.copyWith(color: Colors.grey),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Chờ duyệt', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ] else if (isFailed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Thất bại', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          Text(
            '$prefix${currencyFormat.format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    // Step 1: Input Amount, Step 2: Show QR
    int currentStep = 1; 
    double depositAmount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentStep == 1 ? 'Nạp tiền vào ví' : 'Thanh toán QR',
                      style: AppTheme.heading2,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: currentStep == 1 
                    ? _buildDepositInputStep(amountController, () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount < 10000) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tối thiểu 10,000đ'), backgroundColor: AppColors.error),
                          );
                          return;
                        }
                        setStateDialog(() {
                          depositAmount = amount;
                          currentStep = 2;
                        });
                      })
                    : _buildDepositQRStep(depositAmount, () {
                        _submitDeposit(depositAmount);
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepositInputStep(TextEditingController controller, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập số tiền bạn muốn nạp',
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTheme.heading3.copyWith(color: AppColors.accent, fontSize: 32),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'đ',
            prefixIcon: const Icon(Icons.attach_money, color: AppColors.accent, size: 28),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        // Suggested amounts
        Wrap(
          spacing: 8,
          children: [50000, 100000, 200000, 500000].map((amount) {
            final formatted = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(amount);
            return ActionChip(
              label: Text(formatted),
              backgroundColor: AppColors.surfaceLight,
              onPressed: () => controller.text = amount.toStringAsFixed(0),
            );
          }).toList(),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('TIẾP TỤC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildDepositQRStep(double amount, VoidCallback onConfirm) {
    // VietQR URL
    final bankId = 'MB';
    final accountNo = '0336063462'; 
    final accountName = 'PCM PICKLEBALL';
    final content = 'NAP ${amount.toInt()}';
    final qrUrl = 'https://img.vietqr.io/image/$bankId-$accountNo-compact.png?amount=${amount.toInt()}&addInfo=$content&accountName=$accountName';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('Quét mã QR để thanh toán', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Image.network(
                qrUrl,
                height: 200,
                width: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200, 
                    child: Center(child: CircularProgressIndicator())
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(amount),
                style: AppTheme.heading1.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sau khi chuyển khoản thành công, vui lòng nhấn "Đã chuyển tiền" để hệ thống xử lý.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('ĐÃ CHUYỂN TIỀN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitDeposit(double amount) async {
    final auth = context.read<AuthProvider>();
    final api = ApiService();

    try {
        final res = await api.post(
          '${ApiConfig.wallet}/deposit',
          data: {
            'memberId': auth.userId,
            'amount': amount,
            'evidenceUrl': 'QR_AUTO_PAY', 
          },
        );

        if (res.statusCode == 200) {
          if (mounted) {
            Navigator.pop(context); 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Yêu cầu nạp tiền đã được gửi! Đang chờ duyệt...'),
                backgroundColor: AppColors.warning,
              ),
            );
            _loadData(); // Refresh wallet data
          }
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
