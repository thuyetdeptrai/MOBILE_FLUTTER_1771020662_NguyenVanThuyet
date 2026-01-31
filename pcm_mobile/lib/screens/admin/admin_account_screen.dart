import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../login_screen.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.verified_user, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Quản Trị Viên',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? '',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
