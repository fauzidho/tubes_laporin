import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';
import '../models/report_status.dart';
import '../models/notification_model.dart';
import '../core/utils/file_validation.dart';
import 'notification_provider.dart';
import 'package:path/path.dart' as p;

// Conditional import: dart:io only available on non-web platforms

class ReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReportModel> get allReports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;

  List<ReportModel> getReportsByUser(String userId) {
    return _reports.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int countByStatus(ReportStatus status) =>
      _reports.where((r) => r.status == status).length;

  int get totalReports => _reports.length;
  int get pendingCount => countByStatus(ReportStatus.pending);
  int get inProgressCount => countByStatus(ReportStatus.inProgress);
  int get resolvedCount => countByStatus(ReportStatus.resolved);

  int getUserTotalReports(String userId) =>
      _reports.where((r) => r.userId == userId).length;
      
  int getUserCountByStatus(String userId, ReportStatus status) =>
      _reports.where((r) => r.userId == userId && r.status == status).length;
      
  int getUserPendingCount(String userId) => getUserCountByStatus(userId, ReportStatus.pending);
  int getUserInProgressCount(String userId) => getUserCountByStatus(userId, ReportStatus.inProgress);
  int getUserResolvedCount(String userId) => getUserCountByStatus(userId, ReportStatus.resolved);

  List<ReportModel> get recentReports {
    final sorted = List<ReportModel>.from(_reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  ReportProvider() {
    _listenToReports();
  }

  void _listenToReports() {
    _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _reports = snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addReport({
    required String userId,
    required String userName,
    required String userNim,
    required String title,
    required ReportCategory category,
    required String location,
    required String description,
    XFile? photo, // Menggunakan XFile untuk dukungan cross-platform (Web/Mobile/Desktop)
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? uploadUrl;

      // ====== CLOUDINARY UPLOAD LOGIC ======
      // Gunakan Cloudinary sebagai pengganti Firebase Storage
      if (photo != null) {
        debugPrint('Membaca bytes foto...');
        final bytes = await photo.readAsBytes().timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Gagal membaca foto: Waktu habis.');
        });
        
        debugPrint('Mulai upload foto ke Cloudinary...');
        
        // --- KONFIGURASI CLOUDINARY ---
        const String cloudName = 'dsss0rc4a';
        const String uploadPreset = 'MASUKKAN_NAMA_PRESET_DI_SINI'; // Ganti ini nanti!
        
        // Deteksi jenis file untuk Cloudinary (image atau video)
        final resourceType = FileValidation.getCloudinaryResourceType(photo.path);
        final extension = p.extension(photo.path);
        
        final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = 'LaporIn_Media' // Folder tujuan di Cloudinary
          ..files.add(http.MultipartFile.fromBytes(
            'file', 
            bytes, 
            filename: '${userId}_${DateTime.now().millisecondsSinceEpoch}$extension',
          ));

        final response = await request.send().timeout(const Duration(seconds: 45), onTimeout: () {
          throw Exception('Upload $resourceType ke Cloudinary waktu habis (Timeout).');
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = json.decode(responseData);
          uploadUrl = jsonResponse['secure_url'];
          debugPrint('Upload Cloudinary Sukses: $uploadUrl');
        } else {
          final responseData = await response.stream.bytesToString();
          throw Exception('Gagal upload ke Cloudinary: ${response.statusCode}\n$responseData');
        }
      }
      // ======================================

      final now = DateTime.now();

      final report = ReportModel(
        id: '', // Will be managed by Firestore document ID
        userId: userId,
        userName: userName,
        userNim: userNim,
        title: title,
        category: category,
        location: location,
        description: description,
        photoPath: uploadUrl, // Nullable, or URL if uploaded
        status: ReportStatus.pending,
        createdAt: now,
        updatedAt: now,
        timeline: [
          ReportTimeline(
            status: ReportStatus.pending,
            note: 'Laporan diterima oleh sistem',
            timestamp: now,
          ),
        ],
      );

      debugPrint('Menyimpan ke Firestore...');
      final docRef = _firestore.collection('reports').doc();
      await docRef.set(report.copyWith(id: docRef.id).toMap()).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Gagal menyimpan laporan ke Firestore: Waktu habis (Timeout).');
      });
      debugPrint('Laporan berhasil disimpan.');

    } catch (e) {
      debugPrint('Error adding report: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus newStatus,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = _firestore.collection('reports').doc(reportId);
      final now = DateTime.now();
      
      // Get report details for notification
      final report = getReportById(reportId);

      final newTimeline = ReportTimeline(
        status: newStatus,
        note: note ?? 'Status diperbarui',
        timestamp: now,
      );

      await docRef.update({
        'status': newStatus.name,
        'updatedAt': now,
        if (note != null) 'adminNotes': note,
        'timeline': FieldValue.arrayUnion([newTimeline.toMap()]),
      });

      // Send notification to user
      if (report != null) {
        await NotificationProvider.sendNotification(
          userId: report.userId,
          title: 'Update Status Laporan',
          message: 'Laporan "${report.title}" Anda kini berstatus ${newStatus.label}.',
          type: NotificationType.statusUpdate,
          relatedId: reportId,
        );
      }
    } catch (e) {
      debugPrint('Error updating report status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReport(String reportId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String reportId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    try {
      final docRef = _firestore.collection('reports').doc(reportId);
      final now = DateTime.now();

      final comment = ReportComment(
        id: '${userId}_${now.millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        content: content,
        createdAt: now,
      );

      await docRef.update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
        'updatedAt': now,
      });

      // Send notification to report owner
      final report = getReportById(reportId);
      if (report != null && report.userId != userId) {
        await NotificationProvider.sendNotification(
          userId: report.userId,
          title: 'Komentar Baru',
          message: '$userName mengomentari laporan Anda: "$content"',
          type: NotificationType.newComment,
          relatedId: reportId,
        );
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  ReportModel? getReportById(String id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
