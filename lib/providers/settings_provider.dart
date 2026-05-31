import 'package:flutter/material.dart';
import '../core/database/hive_init.dart';
import '../core/database/hive_boxes.dart';
import '../services/cache_service.dart';

/// Manages settings: API keys, offline mode, cache, search preferences.
class SettingsProvider extends ChangeNotifier {
  String _spotifyClientId = '';
  String _spotifyClientSecret = '';
  String _youtubeApiKey = '';
  bool _offlineMode = false;
  bool _saveSearchHistory = true;
  String _defaultSearchFilter = 'all';
  String _cacheSizeText = 'Calculating...';

  SettingsProvider() {
    _loadFromHive();
    _calculateCacheSize();
  }

  // Getters
  String get spotifyClientId => _spotifyClientId;
  String get spotifyClientSecret => _spotifyClientSecret;
  String get youtubeApiKey => _youtubeApiKey;
  bool get offlineMode => _offlineMode;
  bool get saveSearchHistory => _saveSearchHistory;
  String get defaultSearchFilter => _defaultSearchFilter;
  String get cacheSizeText => _cacheSizeText;
  bool get hasSpotifyCredentials =>
      _spotifyClientId.isNotEmpty && _spotifyClientSecret.isNotEmpty;
  bool get hasYoutubeKey => _youtubeApiKey.isNotEmpty;

  void _loadFromHive() {
    final box = HiveInit.settingsBox;
    _spotifyClientId =
        box.get(HiveBoxes.spotifyClientId, defaultValue: '') as String;
    _spotifyClientSecret =
        box.get(HiveBoxes.spotifyClientSecret, defaultValue: '') as String;
    _youtubeApiKey =
        box.get(HiveBoxes.youtubeApiKey, defaultValue: '') as String;
    _offlineMode =
        box.get(HiveBoxes.offlineMode, defaultValue: false) as bool;
    _saveSearchHistory =
        box.get(HiveBoxes.saveSearchHistory, defaultValue: true) as bool;
    _defaultSearchFilter =
        box.get(HiveBoxes.defaultSearchFilter, defaultValue: 'all') as String;
  }

  // Setters
  void setSpotifyCredentials(String clientId, String clientSecret) {
    _spotifyClientId = clientId;
    _spotifyClientSecret = clientSecret;
    final box = HiveInit.settingsBox;
    box.put(HiveBoxes.spotifyClientId, clientId);
    box.put(HiveBoxes.spotifyClientSecret, clientSecret);
    notifyListeners();
  }

  void setYoutubeApiKey(String key) {
    _youtubeApiKey = key;
    HiveInit.settingsBox.put(HiveBoxes.youtubeApiKey, key);
    notifyListeners();
  }

  void setOfflineMode(bool value) {
    _offlineMode = value;
    HiveInit.settingsBox.put(HiveBoxes.offlineMode, value);
    notifyListeners();
  }

  void setSaveSearchHistory(bool value) {
    _saveSearchHistory = value;
    HiveInit.settingsBox.put(HiveBoxes.saveSearchHistory, value);
    notifyListeners();
  }

  void setDefaultSearchFilter(String filter) {
    _defaultSearchFilter = filter;
    HiveInit.settingsBox.put(HiveBoxes.defaultSearchFilter, filter);
    notifyListeners();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final size = await CacheService.getCacheSize();
      _cacheSizeText = _formatBytes(size);
      notifyListeners();
    } catch (_) {
      _cacheSizeText = '0 MB';
      notifyListeners();
    }
  }

  Future<void> clearAllCache() async {
    await CacheService.clearCache();
    await _calculateCacheSize();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
