// Native implementation using dart:io — available on mobile/desktop platforms.
import 'dart:io';

Future<bool> checkFileExists(String path) async => File(path).existsSync();

Future<File> getFile(String path) async => File(path);
