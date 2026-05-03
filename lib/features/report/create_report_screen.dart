import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import 'widgets/camera_capture_widget.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final PageController _pageCtrl = PageController();

  int _currentStep = 0;
  ReportCategory? _selectedCategory;
  String? _selectedLocation;
  XFile? _capturedPhoto;


  final List<String> _locations = [
    'Gedung Kuliah Umum (GKU) Lt. 1',
    'Gedung Kuliah Umum (GKU) Lt. 2',
    'Gedung Kuliah Umum (GKU) Lt. 3',
    'Gedung Kuliah Umum (GKU) Lt. 4',
    'Gedung FRI Lt. 1',
    'Gedung FRI Lt. 2',
    'Gedung FRI Lt. 3',
    'Gedung FIK Lt. 1',
    'Gedung FIK Lt. 2',
    'Gedung FEB Lt. 1',
    'Gedung FEB Lt. 2',
    'Kantin Mahasiswa',
    'Area Parkir Motor',
    'Area Parkir Mobil',
    'Perpustakaan',
    'Masjid Kampus',
    'Lapangan Olahraga',
    'Toilet Umum Gedung A',
    'Toilet Umum Gedung B',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _floorCtrl.dispose();
    _roomCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedCategory == null) {
      _showError('Pilih kategori laporan terlebih dahulu');
      return;
    }
    if (_currentStep == 1) {
      if (_titleCtrl.text.trim().isEmpty) {
        _showError('Judul laporan wajib diisi');
        return;
      }
      if (_selectedLocation == null) {
        _showError('Pilih lokasi kejadian terlebih dahulu');
        return;
      }
      if (_descCtrl.text.trim().isEmpty) {
        _showError('Deskripsi masalah wajib diisi');
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.statusRejected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final reportProvider = context.read<ReportProvider>();
    final user = auth.currentUser!;

    try {
      await reportProvider.addReport(
        userId: user.id,
        userName: user.name,
        userNim: user.nim,
        title: _titleCtrl.text.trim(),
        category: _selectedCategory!,
        location: _selectedLocation!,
        floor: _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
        roomNumber: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        photo: _capturedPhoto,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Laporan berhasil dikirim!'),
            backgroundColor: AppColors.statusResolved,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal mengirim laporan:\n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buat Laporan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildStepIndicator(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Kategori', 'Detail', 'Foto'];
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final label = e.value;
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // STEP 1: Pilih Kategori
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Kategori',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Apa jenis masalah yang ingin dilaporkan?',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ...ReportCategory.values.map(
            (cat) => GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _selectedCategory == cat
                      ? cat.color.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedCategory == cat
                        ? cat.color
                        : AppColors.border,
                    width: _selectedCategory == cat ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 
                            _selectedCategory == cat ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.label,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory == cat
                                  ? cat.color
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _categoryDesc(cat),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCategory == cat)
                      Icon(Icons.check_circle_rounded,
                          color: cat.color, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryDesc(ReportCategory cat) {
    switch (cat) {
      case ReportCategory.kebersihan:
        return 'Sampah, toilet kotor, lingkungan tidak bersih';
      case ReportCategory.kerusakan:
        return 'AC, proyektor, kursi, pintu, lampu rusak';
      case ReportCategory.keamanan:
        return 'Pencurian, kecelakaan, ancaman keamanan';
      case ReportCategory.lainnya:
        return 'Masalah lain yang tidak termasuk kategori di atas';
    }
  }

  // STEP 2: Isi Detail
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Laporan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Isi informasi laporan dengan lengkap',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _fieldLabel('Judul Laporan *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Contoh: AC Ruang 301 GKU Rusak',
                prefixIcon:
                    Icon(Icons.title_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Lokasi Kejadian *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedLocation,
              hint: Text(
                'Pilih lokasi...',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textHint),
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_rounded,
                    color: AppColors.statusRejected),
              ),
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textPrimary),
              items: _locations
                  .map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(
                          l,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLocation = v),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Lantai'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _floorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Cth: 3',
                          prefixIcon: Icon(Icons.layers_rounded, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('No. Ruangan'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _roomCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Cth: 301',
                          prefixIcon: Icon(Icons.door_front_door_rounded, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _fieldLabel('Deskripsi Masalah *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Deskripsikan masalah secara detail: sejak kapan, seberapa parah, dampaknya apa...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.description_rounded,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // STEP 3: Ambil Foto
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambil Foto Bukti',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menggunakan aplikasi kamera bawaan perangkat Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            constraints: const BoxConstraints(minHeight: 400, maxHeight: 600),
            child: CameraCaptureWidget(
              onPhotoTaken: (photo) {
                setState(() => _capturedPhoto = photo);
              },
              onRetake: () {
                setState(() => _capturedPhoto = null);
              },
            ),
          ),

          if (_capturedPhoto == null) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Foto bersifat opsional, namun sangat disarankan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Summary info before submit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Laporan',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _summaryRow('Kategori',
                    _selectedCategory?.label ?? '-'),
                _summaryRow('Judul',
                    _titleCtrl.text.isNotEmpty ? _titleCtrl.text : '-'),
                _summaryRow(
                    'Lokasi', 
                    '${_selectedLocation ?? '-'} '
                    '${_floorCtrl.text.isNotEmpty ? '(Lt. ${_floorCtrl.text})' : ''} '
                    '${_roomCtrl.text.isNotEmpty ? '[R. ${_roomCtrl.text}]' : ''}'),
                _summaryRow('Foto',
                    _capturedPhoto != null ? '✅ Ada' : '⚠️ Tidak ada'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textHint),
            ),
          ),
          const Text(': ',
              style: TextStyle(color: AppColors.textHint)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 2;
    final reportProvider = context.watch<ReportProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Text(
                  'Kembali',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: reportProvider.isLoading
                  ? null
                  : isLastStep
                      ? _submit
                      : _nextStep,
              child: reportProvider.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(isLastStep ? 'Kirim Laporan 🚀' : 'Selanjutnya'),
            ),
          ),
        ],
      ),
    );
  }
}
