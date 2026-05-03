import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Professional Blue
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // Accent - Subdued Orange
  static const Color accent = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFB923C);

  // Background & Surface - Modern Soft
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text - Deep Slate
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status - Soft Pastel Palette
  static const Color statusPending = Color(0xFFFBBF24); // Amber
  static const Color statusPendingBg = Color(0xFFFFFBEB);
  static const Color statusInProgress = Color(0xFF60A5FA); // Blue
  static const Color statusInProgressBg = Color(0xFFEFF6FF);
  static const Color statusResolved = Color(0xFF34D399); // Emerald
  static const Color statusResolvedBg = Color(0xFFECFDF5);
  static const Color statusRejected = Color(0xFFF87171); // Red
  static const Color statusRejectedBg = Color(0xFFFEF2F2);

  // Divider & Border
  static const Color divider = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Shadow - Very soft
  static const Color shadow = Color(0x0A000000);

  // Category colors - Soft
  static const Color catKebersihan = Color(0xFF34D399);
  static const Color catKerusakan = Color(0xFFF87171);
  static const Color catKeamanan = Color(0xFF818CF8);
  static const Color catLainnya = Color(0xFF94A3B8);

  // Gradients - Subtle
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism tokens
  static Color glassBackground(Color baseColor, [double opacity = 0.1]) => 
      baseColor.withValues(alpha: opacity);
  
  static const Color glassBorder = Color(0x1AFFFFFF);
  
  // Premium Shadows - Minimalist
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
