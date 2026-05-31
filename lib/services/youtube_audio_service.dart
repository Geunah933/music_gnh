import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Extracts audio stream URLs from YouTube for full song playback.
class YouTubeAudioService {
  static final YouTubeAudioService _instance = YouTubeAudioService._();
  factory YouTubeAudioService() => _instance;
  YouTubeAudioService._();

  final YoutubeExplode _yt = YoutubeExplode();

  /// Searches YouTube for a song and returns the audio stream URL.
  /// Returns null if no result found.
  Future<String?> getAudioUrl({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final query = '$artistName - $trackName';
      debugPrint('YouTube search: $query');

      final searchResults = await _yt.search.search(query);
      if (searchResults.isEmpty) {
        debugPrint('No YouTube results found');
        return null;
      }

      final video = searchResults.first;
      debugPrint('Found video: ${video.title} (${video.id})');

      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      final audioStreams = manifest.audioOnly.sortByBitrate();

      if (audioStreams.isEmpty) {
        debugPrint('No audio streams found');
        return null;
      }

      // Get the highest quality audio stream
      final audioStream = audioStreams.last;
      debugPrint('Audio stream: ${audioStream.bitrate}bps, ${audioStream.container}');

      return audioStream.url.toString();
    } catch (e) {
      debugPrint('YouTube audio error: $e');
      return null;
    }
  }

  /// Searches YouTube and returns the video ID.
  Future<String?> searchVideoId({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final query = '$artistName - $trackName';
      final searchResults = await _yt.search.search(query);
      if (searchResults.isEmpty) return null;
      return searchResults.first.id.value;
    } catch (e) {
      debugPrint('YouTube search error: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
