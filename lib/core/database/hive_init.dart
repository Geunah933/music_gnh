import 'package:hive_flutter/hive_flutter.dart';
import '../../models/track.dart';
import '../../models/track.g.dart';

/// Initializes Hive database and opens required boxes.
class HiveInit {
  HiveInit._();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register type adapters
    Hive.registerAdapter(TrackAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<Track>('tracks'),
      Hive.openBox<Track>('recentlyPlayed'),
      Hive.openBox<String>('searchHistory'),
      Hive.openBox<String>('playlists'),
      Hive.openBox('settings'),
    ]);
  }

  static Box<Track> get tracksBox => Hive.box<Track>('tracks');
  static Box<Track> get recentlyPlayedBox => Hive.box<Track>('recentlyPlayed');
  static Box<String> get searchHistoryBox => Hive.box<String>('searchHistory');
  static Box<String> get playlistsBox => Hive.box<String>('playlists');
  static Box get settingsBox => Hive.box('settings');
}
