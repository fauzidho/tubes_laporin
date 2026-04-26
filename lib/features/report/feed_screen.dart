import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../models/report_status.dart';
import '../home/widgets/status_badge.dart';
import 'report_detail_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportProvider>().allReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Semua Laporan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: reports.isEmpty
          ? Center(
              child: Text(
                'Belum ada laporan masuk',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 8, color: AppColors.background),
              itemBuilder: (context, index) {
                return _FeedCard(report: reports[index]);
              },
            ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final ReportModel report;
  const _FeedCard({required this.report});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: report.id),
        ),
      ),
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      _getInitials(report.userName),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.userName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          report.location,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: report.status),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Image
            if (report.photoPath != null)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 350,
                ),
                color: Colors.black12,
                child: report.photoPath!.startsWith('http')
                    ? Image.network(
                        report.photoPath!,
                        fit: BoxFit.cover,
                      )
                    : kIsWeb
                        ? const Center(child: Icon(Icons.image))
                        : Image.file(
                            File(report.photoPath!),
                            fit: BoxFit.cover,
                          ),
              )
            else
              Container(
                width: double.infinity,
                height: 160,
                color: report.category.color.withValues(alpha: 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(report.category.icon,
                        size: 48, color: report.category.color),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada foto',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(report.category.icon, size: 16, color: report.category.color),
                      const SizedBox(width: 6),
                      Text(
                        report.category.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: report.category.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(report.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
