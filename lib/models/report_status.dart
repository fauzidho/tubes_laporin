import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum ReportStatus { pending, inProgress, resolved, rejected }

enum ReportCategory { kebersihan, kerusakan, keamanan, lainnya }

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Menunggu';
      case ReportStatus.inProgress:
        return 'Diproses';
      case ReportStatus.resolved:
        return 'Selesai';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return AppColors.statusPending;
      case ReportStatus.inProgress:
        return AppColors.statusInProgress;
      case ReportStatus.resolved:
        return AppColors.statusResolved;
      case ReportStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ReportStatus.pending:
        return AppColors.statusPendingBg;
      case ReportStatus.inProgress:
        return AppColors.statusInProgressBg;
      case ReportStatus.resolved:
        return AppColors.statusResolvedBg;
      case ReportStatus.rejected:
        return AppColors.statusRejectedBg;
    }
  }

  IconData get icon {
    switch (this) {
      case ReportStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ReportStatus.inProgress:
        return Icons.sync_rounded;
      case ReportStatus.resolved:
        return Icons.check_circle_rounded;
      case ReportStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'inProgress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}

extension ReportCategoryX on ReportCategory {
  String get label {
    switch (this) {
      case ReportCategory.kebersihan:
        return 'Kebersihan';
      case ReportCategory.kerusakan:
        return 'Kerusakan';
      case ReportCategory.keamanan:
        return 'Keamanan';
      case ReportCategory.lainnya:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportCategory.kebersihan:
        return Icons.cleaning_services_rounded;
      case ReportCategory.kerusakan:
        return Icons.build_rounded;
      case ReportCategory.keamanan:
        return Icons.security_rounded;
      case ReportCategory.lainnya:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReportCategory.kebersihan:
        return AppColors.catKebersihan;
      case ReportCategory.kerusakan:
        return AppColors.catKerusakan;
      case ReportCategory.keamanan:
        return AppColors.catKeamanan;
      case ReportCategory.lainnya:
        return AppColors.catLainnya;
    }
  }

  static ReportCategory fromString(String value) {
    switch (value) {
      case 'kebersihan':
        return ReportCategory.kebersihan;
      case 'kerusakan':
        return ReportCategory.kerusakan;
      case 'keamanan':
        return ReportCategory.keamanan;
      default:
        return ReportCategory.lainnya;
    }
  }
}
