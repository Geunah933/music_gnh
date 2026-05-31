/// API endpoint constants.
class ApiConstants {
  ApiConstants._();

  // Spotify
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/api/token';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String spotifySearchEndpoint = '/search';

  // YouTube Data API v3
  static const String youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String youtubeSearchEndpoint = '/search';

  // Lyrics
  static const String lyricsOvhBaseUrl = 'https://api.lyrics.ovh/v1';

  // YouTube URL for launching
  static String youtubeVideoUrl(String videoId) =>
      'https://www.youtube.com/watch?v=$videoId';
  static String youtubeAppUrl(String videoId) =>
      'youtube://www.youtube.com/watch?v=$videoId';
}
