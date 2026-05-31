import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../core/database/hive_init.dart';

/// Cache management service for images and metadata.
class CacheService {
  CacheService._();

  /// Calculates total cache size in bytes (Hive boxes + image cache).
  static Future<int> getCacheSize() async {
    int totalSize = 0;

    // Hive box sizes
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory(appDir.path);
      if (hiveDir.existsSync()) {
        await for (final entity in hiveDir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.hive')) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (_) {}

    // Image cache size
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(tempDir.path);
      if (cacheDir.existsSync()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (_) {}

    return totalSize;
  }

  /// Clears all cached images and Hive track data.
  static Future<void> clearCache() async {
    // Clear image cache
    await DefaultCacheManager().emptyCache();

    // Clear tracks box
    final tracksBox = HiveInit.tracksBox;
    await tracksBox.clear();

    // Clear search history
    final historyBox = HiveInit.searchHistoryBox;
    await historyBox.clear();
  }
}
