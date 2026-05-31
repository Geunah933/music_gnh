/// Unified search result model for Spotify and Deezer API responses.
class SearchResult {
  final String id;
  final String name;
  final String subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final Map<String, dynamic>? rawJson;
  final String source; // 'spotify' or 'deezer'

  const SearchResult({
    required this.id,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    this.rawJson,
    this.source = 'spotify',
  });

  // ── Spotify parsers ──

  factory SearchResult.fromSpotifyTrack(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;
    final images = album?['images'] as List<dynamic>?;

    return SearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle:
          '${artists?.isNotEmpty == true ? artists!.first['name'] : 'Unknown'} • Song',
      imageUrl:
          images?.isNotEmpty == true ? images!.first['url'] as String : null,
      type: SearchResultType.track,
      rawJson: json,
      source: 'spotify',
    );
  }

  factory SearchResult.fromSpotifyAlbum(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>?;
    final images = json['images'] as List<dynamic>?;

    return SearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle:
          '${artists?.isNotEmpty == true ? artists!.first['name'] : 'Unknown'} • Album',
      imageUrl:
          images?.isNotEmpty == true ? images!.first['url'] as String : null,
      type: SearchResultType.album,
      rawJson: json,
      source: 'spotify',
    );
  }

  factory SearchResult.fromSpotifyArtist(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;

    return SearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: 'Artist',
      imageUrl:
          images?.isNotEmpty == true ? images!.first['url'] as String : null,
      type: SearchResultType.artist,
      rawJson: json,
      source: 'spotify',
    );
  }

  // ── Deezer parsers ──

  factory SearchResult.fromDeezerTrack(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;

    return SearchResult(
      id: json['id'].toString(),
      name: json['title'] as String? ?? 'Unknown',
      subtitle:
          '${artist?['name'] ?? 'Unknown'} • Song',
      imageUrl: album?['cover_medium'] as String? ??
          album?['cover'] as String?,
      type: SearchResultType.track,
      rawJson: json,
      source: 'deezer',
    );
  }

  factory SearchResult.fromDeezerAlbum(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;

    return SearchResult(
      id: json['id'].toString(),
      name: json['title'] as String? ?? 'Unknown',
      subtitle:
          '${artist?['name'] ?? 'Unknown'} • Album',
      imageUrl: json['cover_medium'] as String? ??
          json['cover'] as String?,
      type: SearchResultType.album,
      rawJson: json,
      source: 'deezer',
    );
  }

  factory SearchResult.fromDeezerArtist(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      subtitle: 'Artist',
      imageUrl: json['picture_medium'] as String? ??
          json['picture'] as String?,
      type: SearchResultType.artist,
      rawJson: json,
      source: 'deezer',
    );
  }
}

enum SearchResultType { track, album, artist }
