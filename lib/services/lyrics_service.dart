import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

/// Lyrics fetching service using lyrics.ovh API.
class LyricsService {
  LyricsService._();

  /// Fetches lyrics for a given artist and track title.
  /// Returns null if lyrics are not found.
  static Future<String?> fetchLyrics({
    required String artist,
    required String title,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.lyricsOvhBaseUrl}'
        '/${Uri.encodeComponent(artist)}'
        '/${Uri.encodeComponent(title)}',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lyrics = data['lyrics'] as String?;
        if (lyrics != null && lyrics.trim().isNotEmpty) {
          return lyrics.trim();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
