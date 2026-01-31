import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../core/services/notification_service.dart';
import 'home/home_screen.dart';
import 'booking/booking_calendar_screen.dart';
import 'tournament/tournament_screen.dart';
import 'wallet/wallet_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_account_screen.dart';
import 'profile/profile_screen.dart';

/// Main Layout - Layout chính với BottomNavigationBar
/// Điều hướng giữa các màn hình chính của app

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }
  
  Future<void> _initNotifications() async {
    final auth = context.read<AuthProvider>();
    final notificationService = context.read<NotificationService>();
    
    if (auth.userId != null) {
      await notificationService.initialize(auth.userId!);
    }
  }

  List<NavigationItem> _buildNavItems(bool isAdmin) {
    if (isAdmin) {
      return const [
        NavigationItem(icon: Icons.dashboard_customize_rounded, label: 'Admin'),
        NavigationItem(icon: Icons.person_rounded, label: 'Cá nhân'),
      ];
    }

    return const [
      NavigationItem(icon: Icons.home_rounded, label: 'Trang chủ'),
      NavigationItem(icon: Icons.calendar_month_rounded, label: 'Đặt sân'),
      NavigationItem(icon: Icons.emoji_events_rounded, label: 'Giải đấu'),
      NavigationItem(icon: Icons.account_balance_wallet_rounded, label: 'Ví'),
      NavigationItem(icon: Icons.person_rounded, label: 'Cá nhân'),
    ];
  }
  
  List<Widget> _buildScreens(bool isAdmin) {
    if (isAdmin) {
      return const [
        AdminDashboardScreen(),
        AdminAccountScreen(),
      ];
    }

    return const [
      HomeScreen(),
      BookingCalendarScreen(),
      TournamentScreen(),
      WalletScreen(),
      ProfileScreen(),
    ];
  }
  


  void _showNotificationsDialog() {
    final notificationService = context.read<NotificationService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer<NotificationService>(
          builder: (context, ns, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Thông báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(
                      onPressed: () => ns.markAllAsRead(),
                      child: Text('Đọc tất cả', style: TextStyle(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ns.notifications.isEmpty
                    ? Center(child: Text('Không có thông báo', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: ns.notifications.length,
                        itemBuilder: (context, index) {
                          final n = ns.notifications[index];
                          return ListTile(
                            leading: Text(n.iconName, style: TextStyle(fontSize: 24)),
                            title: Text(n.title, style: TextStyle(
                              color: Colors.white,
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                            )),
                            subtitle: Text(n.message, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: !n.isRead ? Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)) : null,
                            onTap: () => ns.markAsRead(n.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider changes to detect Role update
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    
    final navItems = _buildNavItems(isAdmin);
    final screens = _buildScreens(isAdmin);
    
    // Reset index if out of bounds (e.g. logout from admin tab)
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: Consumer<NotificationService>(
        builder: (context, ns, _) => FloatingActionButton(
          backgroundColor: AppColors.accent,
          onPressed: _showNotificationsDialog,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_rounded, color: Colors.white),
              if (ns.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${ns.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(navItems),
    );
  }

  Widget _buildBottomNav(List<NavigationItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _currentIndex == index;
              
              return _buildNavItem(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                onTap: () => setState(() => _currentIndex = index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  
  const NavigationItem({required this.icon, required this.label});
}
