import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../login_screen.dart';
import '../history_screen.dart';

/// Profile Screen - Trang cá nhân

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final user = auth.currentUser;
          if (user == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(user),
                const SizedBox(height: 24),

                // Menu Items
                _buildMenuSection(context),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context, auth),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return _buildDigitalMemberCard(user);
  }

  Widget _buildDigitalMemberCard(User user) {
    // Define Gradients based on Tier
    LinearGradient getTierGradient(String tier) {
      switch (tier.toLowerCase()) {
        case 'diamond':
          return const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'gold':
          return const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'silver':
          return const LinearGradient(
            colors: [Color(0xFFE0E0E0), Color(0xFF757575)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        default: // Bronze
          return const LinearGradient(
            colors: [Color(0xFFCD7F32), Color(0xFFA0522D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    }

    final gradient = getTierGradient(user.tier);
    final isDiamond = user.tier.toLowerCase() == 'diamond';

    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Optional opacity)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.sports_tennis, 
              size: 200, 
              color: Colors.white.withOpacity(0.1)
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MEMBER CARD',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9), 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    'PCM CLUB',
                    style: GoogleFonts.outfit(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              // User Info Row
              Row(
                children: [
                  // Avatar with Border
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: user.avatarUrl != null 
                        ? NetworkImage(user.avatarUrl!) 
                        : null,
                      child: user.avatarUrl == null 
                        ? Icon(Icons.person, size: 32, color: gradient.colors.last) 
                        : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                            ],
                          ),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${user.username}',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footer / Tier Label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        user.tier.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  if (isDiamond)
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
          
          // Gloss Effect (Overlay)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(User user) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.sports_tennis,
          value: '${user.rankLevel.toStringAsFixed(1)}',
          label: 'DUPR Rank',
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.emoji_events,
          value: '5',
          label: 'Giải đấu',
          color: AppColors.warning,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.calendar_today,
          value: '23',
          label: 'Trận đấu',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.heading3.copyWith(color: color)),
            Text(label, style: AppTheme.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'Lịch sử đặt sân',
            onTap: () {
               // Navigate to History
               final auth = context.read<AuthProvider>();
               Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(memberId: auth.userId)));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.leaderboard,
            title: 'Bảng xếp hạng',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security,
            title: 'Bảo mật & Tài khoản',
            onTap: () {
               // Open Security settings
               _showSettingsDialog(context); 
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: AppTheme.bodyLarge),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.surfaceLight,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, auth),
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cài đặt', style: AppTheme.heading3),
            const SizedBox(height: 20),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Chỉnh sửa thông tin',
              onTap: () {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Lịch sử đặt sân',
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              onTap: () {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            _buildMenuItem(
              icon: Icons.dark_mode_outlined,
              title: 'Giao diện tối',
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeColor: AppColors.accent,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (ctx.mounted) {
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
