import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class FileValidation {
  FileValidation._();

  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.heic',
    '.heif',
  ];

  static const List<String> allowedVideoExtensions = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.flv',
    '.wmv',
  ];

  /// Returns true if the file is an image or video.
  static bool isValidMedia(XFile file) {
    final ext = p.extension(file.path).toLowerCase();
    return allowedImageExtensions.contains(ext) || allowedVideoExtensions.contains(ext);
  }

  /// Returns true if the file is an image.
  static bool isImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return allowedImageExtensions.contains(ext);
  }

  /// Returns true if the file is a video.
  static bool isVideo(String path) {
    final ext = p.extension(path).toLowerCase();
    return allowedVideoExtensions.contains(ext);
  }

  /// Returns the media type for Cloudinary resource_type.
  static String getCloudinaryResourceType(String path) {
    return isVideo(path) ? 'video' : 'image';
  }
}
