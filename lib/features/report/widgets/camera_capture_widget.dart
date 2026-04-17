import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
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
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    // Pada platform web, kamera hardware tidak dapat diakses
    // menggunakan package camera. Gunakan image_picker sebagai fallback.
    if (kIsWeb) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
      return;
    }

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

  Future<void> _pickImageFromWeb() async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() => _capturedPhoto = photo);
        widget.onPhotoTaken(photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    }
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
    setState(() => _capturedPhoto = null);
    widget.onRetake?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Sudah ambil foto – tampilkan preview
    if (_capturedPhoto != null) {
      return _buildPhotoPreview();
    }

    // Web platform: gunakan image picker sebagai pengganti live camera
    if (kIsWeb) {
      return _buildWebPhotoPickerUI();
    }

    // Error state (mobile)
    if (_hasError) {
      return _buildErrorState();
    }

    // Loading state (mobile)
    if (!_isInitialized) {
      return _buildLoadingState();
    }

    // Live camera preview (mobile)
    return _buildCameraPreview();
  }

  Widget _buildWebPhotoPickerUI() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload Foto Bukti',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Pilih foto dari perangkat Anda sebagai bukti laporan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickImageFromWeb,
            icon: const Icon(Icons.photo_library_rounded, size: 18),
            label: Text(
              'Pilih Foto',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Camera preview
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_cameras.length > 1)
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flip_camera_android_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Center(
                      child: _isCapturing
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white),
                            )
                          : Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hint text
          Positioned(
            bottom: 8,
            child: Text(
              'Tap untuk mengambil foto',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          kIsWeb
              ? Image.network(
                  _capturedPhoto!.path,
                  width: double.infinity,
                  fit: BoxFit.contain,
                )
              : Image.file(
                  File(_capturedPhoto!.path),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _retake,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Ambil Ulang',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.statusResolved,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Foto Diambil',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildLoadingState() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Memuat kamera...',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'Kamera tidak tersedia',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initCamera();
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            label: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
