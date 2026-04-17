import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_model.dart';
import '../../models/report_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../home/widgets/report_card.dart';
import 'admin_reports_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reports = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.admin_panel_settings_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Admin Panel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 18),
                              ),
                              onPressed: () =>
                                  context.read<AuthProvider>().logout(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat datang, ${auth.currentUser?.name ?? 'Admin'} 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AdminStatsGrid(reports: reports),
                  const SizedBox(height: 24),
                  _CategoryBreakdown(reports: reports),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Laporan Terbaru',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AdminReportsScreen())),
                        child: Text(
                          'Lihat Semua →',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...reports.recentReports.map(
                    (r) => ReportCard(
                      report: r,
                      showUser: true,
                      onTap: () => _showUpdateStatusDialog(context, r),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminReportsScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
        label: Text(
          'Semua Laporan',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, ReportModel report) {
    ReportStatus selectedStatus = report.status;
    final noteCtrl = TextEditingController(text: report.adminNotes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Update Status Laporan',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(report.title,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                if (report.photoPath != null)
                  Container(
                    width: double.infinity,
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      report.photoPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36)),
                    ),
                  ),
                Text('Status',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReportStatus.values.map((s) {
                    final isSel = selectedStatus == s;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? s.color : s.backgroundColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: s.color
                                  .withValues(alpha: isSel ? 1.0 : 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.icon,
                                size: 14,
                                color: isSel ? Colors.white : s.color),
                            const SizedBox(width: 6),
                            Text(s.label,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSel ? Colors.white : s.color)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Catatan Admin',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan catatan penanganan...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await context.read<ReportProvider>().updateReportStatus(
                            reportId: report.id,
                            newStatus: selectedStatus,
                            note: noteCtrl.text.isNotEmpty
                                ? noteCtrl.text
                                : null,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Status berhasil diperbarui'),
                            backgroundColor: AppColors.statusResolved,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminStatsGrid extends StatelessWidget {
  final ReportProvider reports;
  const _AdminStatsGrid({required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Laporan',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8))),
                  Text('${reports.totalReports}',
                      style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1)),
                  Text('laporan masuk',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
              const Icon(Icons.assignment_rounded,
                  size: 60, color: Colors.white24),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Menunggu',
                value: reports.pendingCount,
                icon: Icons.hourglass_empty_rounded,
                color: AppColors.statusPending,
                bgColor: AppColors.statusPendingBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: 'Diproses',
                value: reports.inProgressCount,
                icon: Icons.sync_rounded,
                color: AppColors.statusInProgress,
                bgColor: AppColors.statusInProgressBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: 'Selesai',
                value: reports.resolvedCount,
                icon: Icons.check_circle_rounded,
                color: AppColors.statusResolved,
                bgColor: AppColors.statusResolvedBg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text('$value',
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final ReportProvider reports;
  const _CategoryBreakdown({required this.reports});

  @override
  Widget build(BuildContext context) {
    final cats = {
      ReportCategory.kerusakan: reports.allReports
          .where((r) => r.category == ReportCategory.kerusakan)
          .length,
      ReportCategory.kebersihan: reports.allReports
          .where((r) => r.category == ReportCategory.kebersihan)
          .length,
      ReportCategory.keamanan: reports.allReports
          .where((r) => r.category == ReportCategory.keamanan)
          .length,
      ReportCategory.lainnya: reports.allReports
          .where((r) => r.category == ReportCategory.lainnya)
          .length,
    };
    final total = reports.totalReports == 0 ? 1 : reports.totalReports;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori Laporan',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...cats.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(e.key.icon, size: 16, color: e.key.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e.key.label,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                      ),
                      Text('${e.value} laporan',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: e.key.color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / total,
                      backgroundColor:
                          e.key.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(e.key.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
