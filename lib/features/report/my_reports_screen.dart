import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import 'report_detail_screen.dart';
import '../home/widgets/report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  ReportStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final user = auth.currentUser!;
    var userReports = reportProvider.getReportsByUser(user.id);

    if (_filterStatus != null) {
      userReports =
          userReports.where((r) => r.status == _filterStatus).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Saya'),
        backgroundColor: AppColors.primary,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.assignment_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ...ReportStatus.values.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: s.label,
                        isSelected: _filterStatus == s,
                        onTap: () => setState(() => _filterStatus = s),
                        color: s.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: userReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textHint.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          _filterStatus == null
                              ? 'Belum ada laporan'
                              : 'Tidak ada laporan ${_filterStatus!.label}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: userReports.length,
                    itemBuilder: (ctx, i) => ReportCard(
                      report: userReports[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReportDetailScreen(reportId: userReports[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
          ),
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
