import 'package:flutter/material.dart';

/// Custom localization delegate supporting English and Bahasa Indonesia.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  late final Map<String, String> _localizedStrings = _loadStrings();

  Map<String, String> _loadStrings() {
    switch (locale.languageCode) {
      case 'id':
        return _idStrings;
      case 'en':
      default:
        return _enStrings;
    }
  }

  String translate(String key) => _localizedStrings[key] ?? key;

  // Shorthand
  String get appTitle => translate('app_title');
  String get home => translate('home');
  String get search => translate('search');
  String get library => translate('library');
  String get settings => translate('settings');
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get recentSearches => translate('recent_searches');
  String get browseAll => translate('browse_all');
  String get whatDoYouWantToListenTo => translate('what_do_you_want_to_listen_to');
  String get topResults => translate('top_results');
  String get playlists => translate('playlists');
  String get artists => translate('artists');
  String get albums => translate('albums');
  String get tracks => translate('tracks');
  String get createPlaylist => translate('create_playlist');
  String get recent => translate('recent');
  String get likedSongs => translate('liked_songs');
  String get yourPlaylists => translate('your_playlists');
  String get advancedSettings => translate('advanced_settings');
  String get settingsDescription => translate('settings_description');
  String get uiSettings => translate('ui_settings');
  String get themeMode => translate('theme_mode');
  String get light => translate('light');
  String get dark => translate('dark');
  String get auto => translate('auto');
  String get accentColor => translate('accent_color');
  String get typographyScale => translate('typography_scale');
  String get adjustGlobalReadability => translate('adjust_global_readability');
  String get dataAndApi => translate('data_and_api');
  String get offlineMode => translate('offline_mode');
  String get forceLocalOnly => translate('force_local_only');
  String get localCache => translate('local_cache');
  String get usedForArtworkAndMetadata => translate('used_for_artwork_and_metadata');
  String get clearCache => translate('clear_cache');
  String get spotifyApiConfiguration => translate('spotify_api_configuration');
  String get youtubeApiConfiguration => translate('youtube_api_configuration');
  String get enterApiKey => translate('enter_api_key');
  String get saveKey => translate('save_key');
  String get update => translate('update');
  String get preferences => translate('preferences');
  String get saveSearchHistory => translate('save_search_history');
  String get keepLocalLog => translate('keep_local_log');
  String get defaultSearchFilter => translate('default_search_filter');
  String get globalAll => translate('global_all');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get sourceVideo => translate('source_video');
  String get openInYoutube => translate('open_in_youtube');
  String get lyrics => translate('lyrics');
  String get lyricsNotAvailable => translate('lyrics_not_available');
  String get trackDetail => translate('track_detail');
  String get searchingLyrics => translate('searching_lyrics');
  String get searchingYoutubeId => translate('searching_youtube_id');
  String get noResults => translate('no_results');
  String get errorOccurred => translate('error_occurred');
  String get cacheCleared => translate('cache_cleared');
  String get playlist => translate('playlist');
  String get song => translate('song');
  String get album => translate('album');
  String get artist => translate('artist');
  String get currentlyForcedToDarkMode => translate('currently_forced_to_dark_mode');

  // ──────────────────────────────────────────────
  // English Strings
  // ──────────────────────────────────────────────
  static const Map<String, String> _enStrings = {
    'app_title': 'MUSIC GNH',
    'home': 'Home',
    'search': 'Search',
    'library': 'Library',
    'settings': 'Settings',
    'good_morning': 'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening': 'Good evening',
    'recent_searches': 'Recent searches',
    'browse_all': 'Browse all',
    'what_do_you_want_to_listen_to': 'What do you want to listen to?',
    'top_results': 'Top Results',
    'playlists': 'Playlists',
    'artists': 'Artists',
    'albums': 'Albums',
    'tracks': 'Tracks',
    'create_playlist': 'Create Playlist',
    'recent': 'Recent',
    'liked_songs': 'Liked Songs',
    'your_playlists': 'Your Playlists',
    'advanced_settings': 'Advanced Settings',
    'settings_description':
        'Configure core application behaviors, API integrations, and personalization preferences.',
    'ui_settings': 'UI Settings',
    'theme_mode': 'Theme Mode',
    'light': 'Light',
    'dark': 'Dark',
    'auto': 'Auto',
    'accent_color': 'Accent Color',
    'typography_scale': 'Typography Scale',
    'adjust_global_readability': 'Adjust global readability',
    'data_and_api': 'Data & API',
    'offline_mode': 'Offline Mode',
    'force_local_only': 'Force local playback only',
    'local_cache': 'Local Cache',
    'used_for_artwork_and_metadata': 'used for artwork and metadata',
    'clear_cache': 'CLEAR CACHE',
    'spotify_api_configuration': 'Spotify API Configuration',
    'youtube_api_configuration': 'YouTube API Configuration',
    'enter_api_key': 'Enter API Key',
    'save_key': 'SAVE KEY',
    'update': 'UPDATE',
    'preferences': 'Preferences',
    'save_search_history': 'Save Search History',
    'keep_local_log': 'Keep a local log of queries',
    'default_search_filter': 'Default Search Filter',
    'global_all': 'Global (All)',
    'language': 'Language',
    'select_language': 'Select Language',
    'source_video': 'Source Video',
    'open_in_youtube': 'Open in YouTube',
    'lyrics': 'Lyrics',
    'lyrics_not_available': 'Lyrics not available for this track.',
    'track_detail': 'Track Detail',
    'searching_lyrics': 'Searching lyrics...',
    'searching_youtube_id': 'Finding YouTube video...',
    'no_results': 'No results found.',
    'error_occurred': 'An error occurred. Please try again.',
    'cache_cleared': 'Cache cleared successfully!',
    'playlist': 'Playlist',
    'song': 'Song',
    'album': 'Album',
    'artist': 'Artist',
    'currently_forced_to_dark_mode': 'Currently forced to Dark Mode',
  };

  // ──────────────────────────────────────────────
  // Bahasa Indonesia Strings
  // ──────────────────────────────────────────────
  static const Map<String, String> _idStrings = {
    'app_title': 'MUSIC GNH',
    'home': 'Beranda',
    'search': 'Cari',
    'library': 'Pustaka',
    'settings': 'Pengaturan',
    'good_morning': 'Selamat pagi',
    'good_afternoon': 'Selamat siang',
    'good_evening': 'Selamat malam',
    'recent_searches': 'Pencarian terakhir',
    'browse_all': 'Jelajahi semua',
    'what_do_you_want_to_listen_to': 'Apa yang ingin kamu dengarkan?',
    'top_results': 'Hasil Teratas',
    'playlists': 'Daftar Putar',
    'artists': 'Artis',
    'albums': 'Album',
    'tracks': 'Lagu',
    'create_playlist': 'Buat Daftar Putar',
    'recent': 'Terbaru',
    'liked_songs': 'Lagu Disukai',
    'your_playlists': 'Daftar Putar Anda',
    'advanced_settings': 'Pengaturan Lanjutan',
    'settings_description':
        'Konfigurasikan perilaku aplikasi, integrasi API, dan preferensi personalisasi.',
    'ui_settings': 'Pengaturan UI',
    'theme_mode': 'Mode Tema',
    'light': 'Terang',
    'dark': 'Gelap',
    'auto': 'Otomatis',
    'accent_color': 'Warna Aksen',
    'typography_scale': 'Skala Tipografi',
    'adjust_global_readability': 'Sesuaikan keterbacaan global',
    'data_and_api': 'Data & API',
    'offline_mode': 'Mode Offline',
    'force_local_only': 'Paksa pemutaran lokal saja',
    'local_cache': 'Cache Lokal',
    'used_for_artwork_and_metadata': 'digunakan untuk artwork dan metadata',
    'clear_cache': 'HAPUS CACHE',
    'spotify_api_configuration': 'Konfigurasi API Spotify',
    'youtube_api_configuration': 'Konfigurasi API YouTube',
    'enter_api_key': 'Masukkan API Key',
    'save_key': 'SIMPAN KEY',
    'update': 'PERBARUI',
    'preferences': 'Preferensi',
    'save_search_history': 'Simpan Riwayat Pencarian',
    'keep_local_log': 'Simpan catatan lokal dari pencarian',
    'default_search_filter': 'Filter Pencarian Default',
    'global_all': 'Global (Semua)',
    'language': 'Bahasa',
    'select_language': 'Pilih Bahasa',
    'source_video': 'Video Sumber',
    'open_in_youtube': 'Buka di YouTube',
    'lyrics': 'Lirik',
    'lyrics_not_available': 'Lirik tidak tersedia untuk lagu ini.',
    'track_detail': 'Detail Lagu',
    'searching_lyrics': 'Mencari lirik...',
    'searching_youtube_id': 'Mencari video YouTube...',
    'no_results': 'Tidak ada hasil ditemukan.',
    'error_occurred': 'Terjadi kesalahan. Silakan coba lagi.',
    'cache_cleared': 'Cache berhasil dihapus!',
    'playlist': 'Daftar Putar',
    'song': 'Lagu',
    'album': 'Album',
    'artist': 'Artis',
    'currently_forced_to_dark_mode': 'Saat ini dipaksa ke Mode Gelap',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
