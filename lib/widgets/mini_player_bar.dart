import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/audio_player_provider.dart';
import '../features/now_playing/now_playing_screen.dart';
import '../widgets/track_cover_art.dart';

/// A persistent mini player bar shown at the bottom of the main shell.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audio, _) {
        if (!audio.hasTrack) return const SizedBox.shrink();

        final track = audio.currentTrack!;
        final cs = Theme.of(context).colorScheme;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const NowPlayingScreen(),
                transitionsBuilder: (_, animation, _, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: LinearProgressIndicator(
                    value: audio.progress,
                    minHeight: 2,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
                  child: Row(
                    children: [
                      // Album art
                      TrackCoverArt(
                        track: track,
                        size: 40,
                        borderRadius: 6,
                        memCacheWidth: 120,
                        fallbackIcon: Icons.music_note_rounded,
                      ),
                      const SizedBox(width: 10),
                      // Track info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              track.artistName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Controls
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: cs.onSurface,
                          size: 24,
                        ),
                        onPressed: audio.hasPrevious ? audio.previous : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      IconButton(
                        icon: audio.isLoadingTrack
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  audio.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  key: ValueKey(audio.isPlaying),
                                  color: cs.onSurface,
                                  size: 30,
                                ),
                              ),
                        onPressed: audio.isLoadingTrack ? null : audio.togglePlayPause,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: cs.onSurface,
                          size: 24,
                        ),
                        onPressed: audio.hasNext ? audio.next : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                          size: 22,
                        ),
                        onPressed: () {
                          audio.clearQueue();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
