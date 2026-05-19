import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists scan photos under app documents so history survives cache clears.
abstract final class ScanImageStorage {
  static const String _subdir = 'scan_history';

  /// Copies [source] into app documents. Returns the new path or null on failure.
  static Future<String?> persistScanImage(File source) async {
    try {
      if (!await source.exists()) return null;

      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, _subdir));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = p.join(dir.path, fileName);
      await source.copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  /// Whether a stored history image is still readable on disk.
  static bool isImageAvailable(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }
}
