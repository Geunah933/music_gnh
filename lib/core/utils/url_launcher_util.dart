import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';

/// Utility for launching external URLs.
class UrlLauncherUtil {
  UrlLauncherUtil._();

  /// Opens a YouTube video by ID, trying the app first then falling back to browser.
  static Future<bool> openYouTubeVideo(String videoId) async {
    // Try YouTube app first
    final appUri = Uri.parse(ApiConstants.youtubeAppUrl(videoId));
    if (await canLaunchUrl(appUri)) {
      return launchUrl(appUri, mode: LaunchMode.externalApplication);
    }
    // Fall back to browser
    final webUri = Uri.parse(ApiConstants.youtubeVideoUrl(videoId));
    return launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  /// Opens any URL in the default browser.
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
