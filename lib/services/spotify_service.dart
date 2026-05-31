import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/search_result.dart';
import '../models/track.dart';

/// Spotify Web API service using Client Credentials flow.
class SpotifyService {
  String? _accessToken;
  DateTime? _tokenExpiry;

  final String clientId;
  final String clientSecret;

  SpotifyService({required this.clientId, required this.clientSecret});

  /// Tests the connection by attempting to authenticate and do a simple search.
  /// Returns a user-friendly message describing the result.
  Future<String> testConnection() async {
    try {
      // Step 1: Try authentication
      _accessToken = null;
      _tokenExpiry = null;

      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      final authResponse = await http.post(
        Uri.parse(ApiConstants.spotifyAuthUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      debugPrint('Test auth status: ${authResponse.statusCode}');
      debugPrint('Test auth body: ${authResponse.body}');

      if (authResponse.statusCode != 200) {
        final body = authResponse.body;
        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          final error = data['error'] ?? '';
          final desc = data['error_description'] ?? '';
          return '❌ Auth failed ($error): $desc';
        } catch (_) {
          return '❌ Auth failed (${authResponse.statusCode}): $body';
        }
      }

      final data = jsonDecode(authResponse.body) as Map<String, dynamic>;
      final token = data['access_token'] as String;

      // Step 2: Try a simple search
      final searchResponse = await http.get(
        Uri.parse(
          '${ApiConstants.spotifyBaseUrl}${ApiConstants.spotifySearchEndpoint}'
          '?q=test&type=track&limit=1',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('Test search status: ${searchResponse.statusCode}');
      debugPrint('Test search body: ${searchResponse.body}');

      if (searchResponse.statusCode == 200) {
        return '✅ Connection successful! Search is working.';
      } else {
        final body = searchResponse.body;
        try {
          final errData = jsonDecode(body) as Map<String, dynamic>;
          final error = errData['error'] as Map<String, dynamic>?;
          final msg = error?['message'] ?? body;
          final status = error?['status'] ?? searchResponse.statusCode;
          return '⚠️ Auth OK, but search failed ($status): $msg';
        } catch (_) {
          return '⚠️ Auth OK, but search failed (${searchResponse.statusCode}): $body';
        }
      }
    } catch (e) {
      return '❌ Connection error: $e';
    }
  }

  /// Authenticates with Spotify and gets an access token.
  Future<void> _authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return; // Token still valid
    }

    // Force re-auth
    _accessToken = null;
    _tokenExpiry = null;

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse(ApiConstants.spotifyAuthUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    debugPrint('Spotify auth response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String;
      final expiresIn = data['expires_in'] as int;
      _tokenExpiry =
          DateTime.now().add(Duration(seconds: expiresIn - 60));
    } else {
      final body = response.body;
      debugPrint('Spotify auth error: $body');
      String errorDetail = '';
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        errorDetail = data['error_description'] ?? data['error'] ?? body;
      } catch (_) {
        errorDetail = body;
      }
      throw Exception(
        'Spotify login failed: $errorDetail\n'
        'Please check Client ID and Client Secret in Settings.',
      );
    }
  }

  /// Searches Spotify for tracks, artists, and albums.
  Future<List<SearchResult>> search(String query, {String type = 'track,artist,album', int limit = 10}) async {
    await _authenticate();

    final uri = Uri.parse(
      '${ApiConstants.spotifyBaseUrl}${ApiConstants.spotifySearchEndpoint}'
      '?q=${Uri.encodeComponent(query)}'
      '&type=$type'
      '&limit=$limit',
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    debugPrint('Spotify search status: ${response.statusCode}');

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Token might be invalid, clear and retry once
      debugPrint('Search failed, retrying with new token...');
      _accessToken = null;
      _tokenExpiry = null;
      await _authenticate();

      final retryResponse = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (retryResponse.statusCode != 200) {
        debugPrint('Retry also failed: ${retryResponse.body}');
        String errorDetail = '';
        try {
          final data = jsonDecode(retryResponse.body) as Map<String, dynamic>;
          final error = data['error'] as Map<String, dynamic>?;
          errorDetail = error?['message'] ?? retryResponse.body;
        } catch (_) {
          errorDetail = retryResponse.body;
        }
        throw Exception('Spotify: $errorDetail');
      }

      return _parseSearchResults(retryResponse.body);
    }

    if (response.statusCode != 200) {
      debugPrint('Search failed: ${response.body}');
      String errorDetail = '';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'] as Map<String, dynamic>?;
        errorDetail = error?['message'] ?? response.body;
      } catch (_) {
        errorDetail = response.body;
      }
      throw Exception('Spotify: $errorDetail');
    }

    return _parseSearchResults(response.body);
  }

  List<SearchResult> _parseSearchResults(String responseBody) {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final results = <SearchResult>[];

    // Parse tracks
    if (data.containsKey('tracks')) {
      final items = (data['tracks']['items'] as List<dynamic>?) ?? [];
      for (final item in items) {
        results.add(SearchResult.fromSpotifyTrack(item as Map<String, dynamic>));
      }
    }

    // Parse artists
    if (data.containsKey('artists')) {
      final items = (data['artists']['items'] as List<dynamic>?) ?? [];
      for (final item in items) {
        results.add(SearchResult.fromSpotifyArtist(item as Map<String, dynamic>));
      }
    }

    // Parse albums
    if (data.containsKey('albums')) {
      final items = (data['albums']['items'] as List<dynamic>?) ?? [];
      for (final item in items) {
        results.add(SearchResult.fromSpotifyAlbum(item as Map<String, dynamic>));
      }
    }

    return results;
  }

  /// Fetches a single track by Spotify ID.
  Future<Track> getTrack(String trackId) async {
    await _authenticate();

    final response = await http.get(
      Uri.parse('${ApiConstants.spotifyBaseUrl}/tracks/$trackId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch track: ${response.statusCode}');
    }

    return Track.fromSpotifyJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
