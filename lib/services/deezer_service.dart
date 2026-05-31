import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../models/track.dart';

/// Deezer API service — FREE, no API key or subscription required.
class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';

  /// Searches Deezer for tracks, artists, and albums.
  Future<List<SearchResult>> search(String query, {int limit = 20}) async {
    final results = <SearchResult>[];

    // Search tracks
    try {
      final trackResponse = await http.get(
        Uri.parse('$_baseUrl/search/track?q=${Uri.encodeComponent(query)}&limit=$limit'),
      );

      if (trackResponse.statusCode == 200) {
        final data = jsonDecode(trackResponse.body) as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        for (final item in items) {
          results.add(SearchResult.fromDeezerTrack(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Deezer track search error: $e');
    }

    // Search artists
    try {
      final artistResponse = await http.get(
        Uri.parse('$_baseUrl/search/artist?q=${Uri.encodeComponent(query)}&limit=5'),
      );

      if (artistResponse.statusCode == 200) {
        final data = jsonDecode(artistResponse.body) as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        for (final item in items) {
          results.add(SearchResult.fromDeezerArtist(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Deezer artist search error: $e');
    }

    // Search albums
    try {
      final albumResponse = await http.get(
        Uri.parse('$_baseUrl/search/album?q=${Uri.encodeComponent(query)}&limit=5'),
      );

      if (albumResponse.statusCode == 200) {
        final data = jsonDecode(albumResponse.body) as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        for (final item in items) {
          results.add(SearchResult.fromDeezerAlbum(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Deezer album search error: $e');
    }

    return results;
  }

  /// Fetches a single track by Deezer ID.
  Future<Track> getTrack(int trackId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/track/$trackId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch track: ${response.statusCode}');
    }

    return Track.fromDeezerJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
