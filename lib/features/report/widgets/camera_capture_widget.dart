import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/file_validation.dart';
import 'package:path/path.dart' as p;

/// Widget kamera langsung (Live Camera) menggunakan package camera Dart.
/// Ini adalah fitur unggulan LaporIn – foto diambil langsung dari kamera
/// tanpa melalui galeri untuk menjamin integritas laporan.
class CameraCaptureWidget extends StatefulWidget {
  final Function(XFile photo) onPhotoTaken;
  final VoidCallback? onRetake;

  const CameraCaptureWidget({
    super.key,
    required this.onPhotoTaken,
    this.onRetake,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

enum CameraSource { camera, gallery, none }

class _CameraCaptureWidgetState extends State<CameraCaptureWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isCapturing = false;
  XFile? _capturedPhoto;
  int _selectedCameraIndex = 0;
  CameraSource _activeSource = CameraSource.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Don't initialize camera immediately unless we are on web
    if (kIsWeb) {
      _activeSource = CameraSource.gallery;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed && _activeSource == CameraSource.camera) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _activeSource = CameraSource.camera;
      _isInitialized = false;
      _hasError = false;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Tidak ada kamera yang tersedia di perangkat ini.';
        });
        return;
      }
      await _setupController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal mengakses kamera: $e';
      });
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Kamera tidak dapat diinisialisasi: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    try {
      // Menggunakan pickMedia untuk mendukung Gambar dan Video sekaligus
      final media = await picker.pickMedia(
        imageQuality: 85,
      );

      if (media != null) {
        // Validasi filterisasi: Hanya menerima gambar dan video
        if (!FileValidation.isValidMedia(media)) {
          if (mounted) {
            _showInvalidFileAlert();
          }
          return;
        }

        setState(() {
          _capturedPhoto = media;
          _activeSource = CameraSource.gallery;
        });
        widget.onPhotoTaken(media);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil media: $e'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    }
  }

  void _showInvalidFileAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.statusRejected),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'File Tidak Didukung',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Maaf, Anda hanya dapat mengunggah file gambar (JPG, PNG, WEBP) atau video (MP4, MOV).',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mengerti', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isInitialized || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final photo = await _controller!.takePicture();
      setState(() {
        _capturedPhoto = photo;
        _isCapturing = false;
      });
      widget.onPhotoTaken(photo);
    } catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _isInitialized = false;
    });
    await _controller?.dispose();
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  void _retake() {
    setState(() {
      _capturedPhoto = null;
      _activeSource = CameraSource.none;
    });
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    widget.onRetake?.call();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Photo already captured
    if (_capturedPhoto != null) {
      return _buildPhotoPreview();
    }

    // 2. Selection Mode (Initial or after retake)
    if (_activeSource == CameraSource.none) {
      return _buildSelectionUI();
    }

    // 3. Camera Mode
    if (_activeSource == CameraSource.camera) {
      if (_hasError) return _buildErrorState();
      if (!_isInitialized) return _buildLoadingState();
      return _buildCameraPreview();
    }

    // 4. Web Fallback / Gallery Mode (already handled by _pickFromGallery usually)
    return _buildSelectionUI();
  }

  Widget _buildSelectionUI() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Lampirkan Bukti Foto',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ambil foto langsung dari lokasi atau pilih dari galeri perangkat Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionButton(
                onTap: _initCamera,
                icon: Icons.camera_rounded,
                label: 'Kamera',
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              _buildOptionButton(
                onTap: _pickFromGallery,
                icon: Icons.photo_library_rounded,
                label: 'Galeri',
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: (isPrimary ? AppColors.primary : Colors.black)
                  .withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview with proper fitting
          Center(
            child: CameraPreview(_controller!),
          ),

          // Close button to go back to selection
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                setState(() => _activeSource = CameraSource.none);
                _controller?.dispose();
                _controller = null;
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_cameras.length > 1)
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flip_camera_android_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isCapturing ? null : _takePicture,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: _isCapturing
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white),
                            )
                          : Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap untuk memotret',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      const Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? Image.network(
                  _capturedPhoto!.path,
                  fit: BoxFit.contain,
                )
              : FileValidation.isVideo(_capturedPhoto!.path)
                  ? Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_rounded, color: Colors.white, size: 64),
                            const SizedBox(height: 12),
                            Text(
                              'Video Terpilih',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              p.basename(_capturedPhoto!.path),
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Image.file(
                      File(_capturedPhoto!.path),
                      fit: BoxFit.contain,
                    ),
          
          // Action buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _retake,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ambil Ulang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.statusResolved,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'Menyiapkan Kamera...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: AppColors.statusRejected),
          const SizedBox(height: 16),
          Text(
            'Kamera Bermasalah',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _activeSource = CameraSource.none),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
