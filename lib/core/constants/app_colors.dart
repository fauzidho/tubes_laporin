import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryLighter = Color(0xFF1976D2);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Accent
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A65);

  // Background & Surface
  static const Color background = Color(0xFFF3F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2FF);

  // Text
  static const Color textPrimary = Color(0xFF0D1B4B);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textHint = Color(0xFF90A4AE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingBg = Color(0xFFFFFBEB);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusInProgressBg = Color(0xFFEFF6FF);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusResolvedBg = Color(0xFFECFDF5);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusRejectedBg = Color(0xFFFEF2F2);

  // Divider
  static const Color divider = Color(0xFFE8EAF6);
  static const Color border = Color(0xFFDDE1F0);

  // Shadow
  static const Color shadow = Color(0x1A0D47A1);

  // Category colors
  static const Color catKebersihan = Color(0xFF10B981);
  static const Color catKerusakan = Color(0xFFEF4444);
  static const Color catKeamanan = Color(0xFF8B5CF6);
  static const Color catLainnya = Color(0xFF6B7280);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0A2F6E), Color(0xFF0D47A1), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
