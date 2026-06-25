import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class FileX {
  FileX._();

  /// Get a human-readable size string ("1.2 MB")
  static String humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int u = -1;
    do {
      size /= 1024;
      u++;
    } while (size >= 1024 && u < units.length - 1);
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[u]}';
  }

  /// Detect MIME type from path (falls back to octet-stream)
  static String? mime(String path) => lookupMimeType(path);

  /// Categorize a file for UI icon selection
  static FileKind kind(String path) {
    final m = mime(path) ?? '';
    if (m.startsWith('image/')) return FileKind.image;
    if (m.startsWith('video/')) return FileKind.video;
    if (m.startsWith('audio/')) return FileKind.audio;
    if (m == 'application/pdf') return FileKind.pdf;
    if (m.contains('zip') || m.contains('rar') || m.contains('7z') || m.contains('tar')) return FileKind.archive;
    if (m.contains('word') || m.contains('excel') || m.contains('powerpoint') || m.contains('opendocument')) return FileKind.doc;
    return FileKind.other;
  }

  static String name(String path) => p.basename(path);
  static String ext(String path) => p.extension(path).toLowerCase();
}

enum FileKind { image, video, audio, pdf, archive, doc, other }
