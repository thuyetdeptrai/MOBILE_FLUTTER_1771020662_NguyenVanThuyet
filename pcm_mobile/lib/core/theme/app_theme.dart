import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme - Modern Light Theme
/// Thiết kế hiện đại, sáng sủa và chuyên nghiệp cho ứng dụng Pickleball

class AppColors {
  // Primary Colors (Brand Identity)
  static const Color primary = Color(0xFF1E3A5F);        // Deep Navy
  static const Color primaryLight = Color(0xFFE3F2FD);   // Very Light Blue (Backgrounds)
  static const Color primaryDark = Color(0xFF0D1F33);    // Darker Navy (Headings)
  
  // Accent Colors
  static const Color accent = Color(0xFF0091EA);         // Bright Blue (Action Buttons)
  static const Color accentLight = Color(0xFFB3E5FC);    // Light Blue Accent
  
  // Status Colors
  static const Color success = Color(0xFF00C853);        // Green
  static const Color warning = Color(0xFFFFAB00);        // Amber
  static const Color error = Color(0xFFD32F2F);          // Red
  static const Color info = Color(0xFF2196F3);           // Blue
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);     // Off-white Background
  static const Color surface = Color(0xFFFFFFFF);        // White Card
  static const Color surfaceLight = Color(0xFFF1F3F4);   // Input Background
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);    // Dark Navy/Black
  static const Color textSecondary = Color(0xFF5F6368);  // Grey
  static const Color textHint = Color(0xFF9AA0A6);       // Light Grey
  static const Color textInverse = Color(0xFFFFFFFF);    // White text on dark bg
  
  // Tier Colors
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFF9E9E9E);     // Darker Silver for visibility
  static const Color tierGold = Color(0xFFFBC02D);       // Darker Gold
  static const Color tierDiamond = Color(0xFF00BCD4);    // Cyan
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF2C5282)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF4FC3F7)],
  );
  
  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90E2), Color(0xFF0052CC)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.outfit( // Changed font for headings
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintStyle: GoogleFonts.outfit(color: AppColors.textHint),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: GoogleFonts.outfit(color: AppColors.textPrimary),
        secondaryLabelStyle: GoogleFonts.outfit(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.fixed, // Sửa từ floating để tránh lỗi off-screen
      ),
    );
  }
  
  // Text Styles (Convenience helpers)
  static TextStyle get heading1 => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get heading2 => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get heading3 => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  static TextStyle get button => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get money => GoogleFonts.robotoMono(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}

// Extension để lấy màu tier
extension TierColor on String {
  Color get tierColor {
    switch (toLowerCase()) {
      case 'diamond':
        return AppColors.tierDiamond;
      case 'gold':
        return AppColors.tierGold;
      case 'silver':
        return AppColors.tierSilver;
      default:
        return AppColors.tierBronze;
    }
  }
}
