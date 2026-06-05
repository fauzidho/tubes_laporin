import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../utils/file_validation.dart';

class CloudinaryService {
  static const String cloudName = 'dsss0rc4a';
  
  // PERHATIAN: Pastikan Anda mengganti ini dengan nama Upload Preset Anda di Cloudinary!
  static const String uploadPreset = 'MASUKKAN_NAMA_PRESET_DI_SINI'; 

  /// Mengunggah file media (foto/video) ke Cloudinary.
  /// Mengembalikan secure_url jika sukses, atau null jika gagal.
  static Future<String?> uploadMedia({
    required XFile file,
    required String folder,
    required String fileNamePrefix,
  }) async {
    try {
      debugPrint('Membaca bytes media...');
      final bytes = await file.readAsBytes().timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Gagal membaca file: Waktu habis.');
      });
      
      debugPrint('Mulai upload ke Cloudinary...');
      final resourceType = FileValidation.getCloudinaryResourceType(file.name);
      final extension = p.extension(file.name);
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes(
          'file', 
          bytes, 
          filename: '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}$extension',
        ));

      final response = await request.send().timeout(const Duration(seconds: 45), onTimeout: () {
        throw Exception('Upload ke Cloudinary waktu habis (Timeout).');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        final uploadUrl = jsonResponse['secure_url'];
        debugPrint('Upload Cloudinary Sukses: $uploadUrl');
        return uploadUrl;
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('Gagal upload ke Cloudinary: ${response.statusCode}\n$responseData');
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      rethrow;
    }
  }
}
