import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/track.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/track_cover_art.dart';

/// Full-screen now playing view with album art, controls, and seek bar.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<AudioPlayerProvider>(
      builder: (context, audio, _) {
        final track = audio.currentTrack;
        if (track == null) {
          Navigator.of(context).pop();
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: cs.surface,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.15),
                  cs.surface,
                  cs.surface,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // ── Top Bar ──
                    _buildTopBar(context, cs),
                    const Spacer(flex: 1),

                    // ── Album Art ──
                    _buildAlbumArt(cs, track),
                    const Spacer(flex: 1),

                    // ── Track Info ──
                    _buildTrackInfo(cs, audio),
                    const SizedBox(height: 24),

                    // ── Seek Bar ──
                    _buildSeekBar(cs, audio),
                    const SizedBox(height: 16),

                    // ── Main Controls ──
                    _buildMainControls(cs, audio),
                    const SizedBox(height: 16),

                    // ── Queue Info ──
                    _buildQueueInfo(cs, audio),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: cs.onSurface, size: 32),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'NOW PLAYING',
            style: AppTextStyles.labelCaps.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            icon: Icon(Icons.queue_music_rounded,
                color: cs.onSurfaceVariant),
            onPressed: () => _showQueue(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(ColorScheme cs, Track track) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: TrackCoverArt(
        track: track,
        size: 300,
        borderRadius: 20,
        memCacheWidth: 600,
        fallbackIcon: Icons.album_rounded,
        fallbackIconSize: 80,
      ),
    );
  }

  Widget _buildTrackInfo(ColorScheme cs, AudioPlayerProvider audio) {
    final track = audio.currentTrack!;
    return Column(
      children: [
        Text(
          track.title,
          style: AppTextStyles.headlineLargeMobile.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '${track.artistName} • ${track.albumName}',
          style: AppTextStyles.bodyLarge.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSeekBar(ColorScheme cs, AudioPlayerProvider audio) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.onSurfaceVariant.withValues(alpha: 0.2),
            thumbColor: cs.primary,
            overlayColor: cs.primary.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: audio.progress,
            onChanged: (value) => audio.seekToProgress(value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audio.formatDuration(audio.position),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                audio.formatDuration(audio.duration),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(ColorScheme cs, AudioPlayerProvider audio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: audio.isShuffleOn ? cs.primary : cs.onSurfaceVariant,
            size: 24,
          ),
          onPressed: audio.toggleShuffle,
        ),
        // Previous
        IconButton(
          icon: Icon(
            Icons.skip_previous_rounded,
            color: cs.onSurface,
            size: 36,
          ),
          onPressed: audio.previous,
        ),
        // Play / Pause
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                audio.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                key: ValueKey(audio.isPlaying),
                color: cs.onPrimary,
                size: 32,
              ),
            ),
            onPressed: audio.togglePlayPause,
          ),
        ),
        // Next
        IconButton(
          icon: Icon(
            Icons.skip_next_rounded,
            color: cs.onSurface,
            size: 36,
          ),
          onPressed: audio.next,
        ),
        // Repeat
        IconButton(
          icon: Icon(
            audio.repeatMode == PlayerRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: audio.repeatMode != PlayerRepeatMode.off
                ? cs.primary
                : cs.onSurfaceVariant,
            size: 24,
          ),
          onPressed: audio.togglePlayerRepeatMode,
        ),
      ],
    );
  }

  Widget _buildQueueInfo(ColorScheme cs, AudioPlayerProvider audio) {
    return Text(
      '${audio.currentIndex + 1} / ${audio.queue.length} tracks in queue',
      style: AppTextStyles.bodyMedium.copyWith(
        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        fontSize: 12,
      ),
    );
  }

  void _showQueue(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Consumer<AudioPlayerProvider>(
          builder: (context, audio, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUEUE',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: cs.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          audio.clearQueue();
                          Navigator.pop(ctx);
                        },
                        child: Text('Clear',
                            style: TextStyle(color: cs.error)),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: audio.queue.length,
                    itemBuilder: (_, i) {
                      final t = audio.queue[i];
                      final isCurrent = i == audio.currentIndex;
                      return ListTile(
                        leading: TrackCoverArt(
                          track: t,
                          size: 40,
                          borderRadius: 4,
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            color: isCurrent ? cs.primary : cs.onSurface,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          t.artistName,
                          style: TextStyle(color: cs.onSurfaceVariant),
                          maxLines: 1,
                        ),
                        trailing: isCurrent
                            ? Icon(Icons.equalizer_rounded,
                                color: cs.primary)
                            : IconButton(
                                icon: Icon(Icons.close,
                                    color: cs.onSurfaceVariant, size: 18),
                                onPressed: () => audio.removeFromQueue(i),
                              ),
                        onTap: () async {
                          await audio.playAll(audio.queue, startIndex: i);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
