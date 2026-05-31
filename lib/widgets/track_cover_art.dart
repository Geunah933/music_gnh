import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/track.dart';

/// A reusable widget that displays track cover art, handling both
/// local file covers and network (album art URL) images with a
/// consistent fallback icon.
class TrackCoverArt extends StatelessWidget {
  final Track track;
  final double size;
  final double borderRadius;
  final int? memCacheWidth;
  final IconData fallbackIcon;
  final double? fallbackIconSize;

  const TrackCoverArt({
    super.key,
    required this.track,
    required this.size,
    this.borderRadius = 6,
    this.memCacheWidth,
    this.fallbackIcon = Icons.music_note,
    this.fallbackIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildImage(cs),
      ),
    );
  }

  Widget _buildImage(ColorScheme cs) {
    // Priority 1: Local cover file
    if (track.absoluteCoverPath != null) {
      return Image.file(
        File(track.absoluteCoverPath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: memCacheWidth,
        errorBuilder: (_, _, _) => _buildFallback(cs),
      );
    }

    // Priority 2: Network album art URL
    if (track.albumArtUrl != null) {
      return CachedNetworkImage(
        imageUrl: track.albumArtUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: memCacheWidth,
        placeholder: (_, _) => _buildFallback(cs),
        errorWidget: (_, _, _) => _buildFallback(cs),
      );
    }

    // Fallback: Icon
    return _buildFallback(cs);
  }

  Widget _buildFallback(ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      color: cs.surfaceContainerHighest,
      child: Icon(
        fallbackIcon,
        color: cs.onSurfaceVariant,
        size: fallbackIconSize ?? (size * 0.4).clamp(16, 48),
      ),
    );
  }
}
