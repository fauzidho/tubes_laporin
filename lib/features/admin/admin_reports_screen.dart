import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_model.dart';
import '../../models/report_status.dart';
import '../../providers/report_provider.dart';
import '../home/widgets/report_card.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    var reports = reportProvider.allReports.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_filterStatus != null) {
      reports = reports.where((r) => r.status == _filterStatus).toList();
    }
    if (_filterCategory != null) {
      reports = reports.where((r) => r.category == _filterCategory).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Laporan'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        label: 'Semua',
                        isSelected: _filterStatus == null,
                        color: AppColors.primary,
                        onTap: () => setState(() => _filterStatus = null),
                      ),
                      ...ReportStatus.values.map((s) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _Chip(
                              label: s.label,
                              isSelected: _filterStatus == s,
                              color: s.color,
                              onTap: () =>
                                  setState(() => _filterStatus = s),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Reports list
          Expanded(
            child: reports.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada laporan',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (ctx, i) => ReportCard(
                      report: reports[i],
                      showUser: true,
                      onTap: () =>
                          _showStatusDialog(context, reports[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, ReportModel report) {
    ReportStatus sel = report.status;
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
                Text('Update Status',
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReportStatus.values.map((s) {
                    final isSel = sel == s;
                    return GestureDetector(
                      onTap: () => setModal(() => sel = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel ? s.color : s.backgroundColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: s.color.withOpacity(isSel ? 1 : 0.3)),
                        ),
                        child: Text(
                          s.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSel ? Colors.white : s.color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan admin (opsional)...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await context
                          .read<ReportProvider>()
                          .updateReportStatus(
                            reportId: report.id,
                            newStatus: sel,
                            note: noteCtrl.text.isNotEmpty
                                ? noteCtrl.text
                                : null,
                          );
                    },
                    child: const Text('Simpan'),
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

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? color : color.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
