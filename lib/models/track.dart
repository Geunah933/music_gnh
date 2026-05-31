import 'package:hive/hive.dart';
import '../core/utils/app_paths.dart';

/// Track model representing a music track (online or local).
class Track extends HiveObject {
  final String spotifyId;
  final String title;
  final String artistName;
  final String albumName;
  final String? albumArtUrl;
  final String? previewUrl;
  final String? localFilePath;
  final String? localCoverPath;
  String? youtubeVideoId;
  String? lyrics;
  final String? year;
  final int? durationMs;
  final bool isLocal;
  final DateTime cachedAt;

  /// Returns the absolute path of the local cover image.
  String? get absoluteCoverPath {
    if (localCoverPath == null) return null;
    if (localCoverPath!.startsWith('/')) {
      return localCoverPath;
    }
    return '${AppPaths.documentsPath}/$localCoverPath';
  }

  /// Returns the absolute path of the local file.
  String? get absoluteFilePath {
    if (localFilePath == null) return null;
    if (localFilePath!.startsWith('/')) {
      return localFilePath;
    }
    return '${AppPaths.documentsPath}/$localFilePath';
  }


  Track({
    required this.spotifyId,
    required this.title,
    required this.artistName,
    required this.albumName,
    this.albumArtUrl,
    this.previewUrl,
    this.localFilePath,
    this.localCoverPath,
    this.youtubeVideoId,
    this.lyrics,
    this.year,
    this.durationMs,
    this.isLocal = false,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  /// Creates a Track from Spotify API JSON response.
  factory Track.fromSpotifyJson(Map<String, dynamic> json) {
    final album = json['album'] as Map<String, dynamic>?;
    final artists = json['artists'] as List<dynamic>?;
    final images = album?['images'] as List<dynamic>?;

    return Track(
      spotifyId: json['id'] as String,
      title: json['name'] as String,
      artistName: artists?.isNotEmpty == true
          ? (artists!.first['name'] as String)
          : 'Unknown Artist',
      albumName: album?['name'] as String? ?? 'Unknown Album',
      albumArtUrl: images?.isNotEmpty == true
          ? (images!.first['url'] as String)
          : null,
      previewUrl: json['preview_url'] as String?,
      year: album?['release_date']?.toString().split('-').first,
      durationMs: json['duration_ms'] as int?,
    );
  }

  /// Creates a Track from Deezer API JSON response.
  factory Track.fromDeezerJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;

    return Track(
      spotifyId: 'deezer_${json['id']}',
      title: json['title'] as String? ?? json['title_short'] as String? ?? 'Unknown',
      artistName: artist?['name'] as String? ?? 'Unknown Artist',
      albumName: album?['title'] as String? ?? 'Unknown Album',
      albumArtUrl: album?['cover_big'] as String? ??
          album?['cover_medium'] as String? ??
          album?['cover'] as String?,
      previewUrl: json['preview'] as String?,
      year: null,
      durationMs: json['duration'] != null
          ? (json['duration'] as int) * 1000
          : null,
    );
  }

  /// Creates a Track from local upload.
  factory Track.fromLocal({
    required String id,
    required String title,
    required String artistName,
    required String albumName,
    required String filePath,
    String? coverPath,
    int? durationMs,
  }) {
    return Track(
      spotifyId: 'local_$id',
      title: title,
      artistName: artistName,
      albumName: albumName,
      localFilePath: filePath,
      localCoverPath: coverPath,
      isLocal: true,
      durationMs: durationMs,
    );
  }

  /// Returns the best available image: local cover, album art URL, or null.
  String? get displayImagePath => absoluteCoverPath ?? albumArtUrl;

  /// Duration formatted as m:ss
  String get durationFormatted {
    if (durationMs == null) return '--:--';
    final minutes = (durationMs! / 60000).floor();
    final seconds = ((durationMs! % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Convert to Map for Hive storage.
  Map<String, dynamic> toMap() => {
        'spotifyId': spotifyId,
        'title': title,
        'artistName': artistName,
        'albumName': albumName,
        'albumArtUrl': albumArtUrl,
        'previewUrl': previewUrl,
        'localFilePath': localFilePath,
        'localCoverPath': localCoverPath,
        'isLocal': isLocal,
        'durationMs': durationMs,
        'year': year,
        'cachedAt': cachedAt.toIso8601String(),
      };

  /// Create Track from Hive Map.
  factory Track.fromMap(Map<String, dynamic> map) => Track(
        spotifyId: map['spotifyId'] as String,
        title: map['title'] as String,
        artistName: map['artistName'] as String,
        albumName: map['albumName'] as String? ?? '',
        albumArtUrl: map['albumArtUrl'] as String?,
        previewUrl: map['previewUrl'] as String?,
        localFilePath: map['localFilePath'] as String?,
        localCoverPath: map['localCoverPath'] as String?,
        isLocal: map['isLocal'] as bool? ?? false,
        durationMs: map['durationMs'] as int?,
        year: map['year'] as String?,
        cachedAt: map['cachedAt'] != null
            ? DateTime.parse(map['cachedAt'] as String)
            : null,
      );

  @override
  String toString() => 'Track($title by $artistName${isLocal ? " [LOCAL]" : ""})';
}
