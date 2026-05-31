import 'package:path_provider/path_provider.dart';

/// Synchronous holder for application paths resolved at startup.
class AppPaths {
  AppPaths._();

  static String? _documentsPath;

  /// Gets the absolute application documents directory path.
  static String get documentsPath {
    if (_documentsPath == null) {
      throw StateError('AppPaths is not initialized. Call AppPaths.initialize() first.');
    }
    return _documentsPath!;
  }

  /// Resolves the documents directory path once at startup.
  static Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _documentsPath = appDir.path;
  }
}
