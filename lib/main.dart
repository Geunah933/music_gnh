import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/database/hive_init.dart';
import 'core/utils/app_paths.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/local_music_provider.dart';
import 'providers/playlist_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppPaths
  await AppPaths.initialize();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await HiveInit.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => LocalMusicProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: const MusicGnhApp(),
    ),
  );
}
