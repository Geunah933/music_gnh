import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

/// YouTube Data API v3 service — searches for video IDs.
class YoutubeService {
  final String apiKey;

  YoutubeService({required this.apiKey});

  /// Searches YouTube for a video matching the given track + artist name.
  /// Returns the videoId of the first result, or null.
  Future<String?> searchVideoId({
    required String trackName,
    required String artistName,
  }) async {
    if (apiKey.isEmpty) return null;

    final query = '$trackName $artistName official';
    final uri = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}${ApiConstants.youtubeSearchEndpoint}'
      '?part=snippet'
      '&q=${Uri.encodeComponent(query)}'
      '&type=video'
      '&maxResults=1'
      '&key=$apiKey',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) return null;

      final firstItem = items.first as Map<String, dynamic>;
      final id = firstItem['id'] as Map<String, dynamic>?;
      return id?['videoId'] as String?;
    } catch (_) {
      return null;
    }
  }
}
