// Stub implementation for web platform where dart:io is not available.
// These functions do nothing on the web.

Future<bool> checkFileExists(String path) async => false;

Future<dynamic> getFile(String path) async => throw UnsupportedError(
      'getFile is not available on web platform.',
    );
