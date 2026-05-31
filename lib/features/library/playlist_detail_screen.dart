import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/track_cover_art.dart';

/// Detail screen for a single playlist — shows tracks, play all, reorder, remove.
class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final playlist = provider.playlists
            .cast<Playlist?>()
            .firstWhere((p) => p?.id == playlistId, orElse: () => null);

        if (playlist == null) {
          return Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: const Center(child: Text('Playlist tidak ditemukan')),
          );
        }

        final tracks = provider.getPlaylistTracks(playlistId);

        return Scaffold(
          backgroundColor: cs.surface,
          body: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: cs.surface,
                foregroundColor: cs.onSurface,
                flexibleSpace: FlexibleSpaceBar(
                  background: _PlaylistHeader(
                    playlist: playlist,
                    cs: cs,
                  ),
                ),
              ),

              // ── Action buttons ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.name,
                              style: AppTextStyles.headlineLargeMobile.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${playlist.trackCount} lagu • ${playlist.totalDurationFormatted}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Play all
                      if (tracks.isNotEmpty)
                        FloatingActionButton(
                          heroTag: 'play_playlist_$playlistId',
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          onPressed: () {
                            context.read<AudioPlayerProvider>().playAll(tracks);
                          },
                          child: const Icon(Icons.play_arrow_rounded, size: 32),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Shuffle button ──
              if (tracks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final shuffled = List<Track>.from(tracks)..shuffle();
                        context.read<AudioPlayerProvider>().playAll(shuffled);
                      },
                      icon: Icon(Icons.shuffle_rounded, color: cs.primary),
                      label: Text('Shuffle Play',
                          style: TextStyle(color: cs.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Track list ──
              if (tracks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.music_off_rounded,
                            size: 48,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Playlist kosong',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cari lagu dan tambahkan ke playlist ini',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _PlaylistTrackTile(
                      track: track,
                      index: index,
                      playlistId: playlistId,
                      allTracks: tracks,
                    );
                  },
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        );
      },
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  final Playlist playlist;
  final ColorScheme cs;

  const _PlaylistHeader({required this.playlist, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withValues(alpha: 0.3),
            cs.surface,
          ],
        ),
      ),
      child: Center(
        child: playlist.coverArtUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: playlist.coverArtUrl!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  memCacheWidth: 360,
                ),
              )
            : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  size: 64,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              ),
      ),
    );
  }
}

class _PlaylistTrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final String playlistId;
  final List<Track> allTracks;

  const _PlaylistTrackTile({
    required this.track,
    required this.index,
    required this.playlistId,
    required this.allTracks,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audio = context.watch<AudioPlayerProvider>();
    final isPlaying = audio.currentTrack?.spotifyId == track.spotifyId;

    return Material(
      color: isPlaying ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<AudioPlayerProvider>().playAll(allTracks, startIndex: index);
        },
        onLongPress: () => _showOptions(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Index
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isPlaying ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              // Cover
              TrackCoverArt(track: track, size: 44, borderRadius: 6),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isPlaying ? cs.primary : cs.onSurface,
                        fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track.artistName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Duration
              Text(
                track.durationFormatted,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              // More options
              IconButton(
                icon: Icon(Icons.more_vert_rounded,
                    color: cs.onSurfaceVariant, size: 20),
                onPressed: () => _showOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.play_arrow_rounded, color: cs.primary),
              title: Text('Putar', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<AudioPlayerProvider>()
                    .playAll(allTracks, startIndex: index);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.queue_music_rounded, color: cs.onSurfaceVariant),
              title: Text('Tambah ke Antrian',
                  style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AudioPlayerProvider>().addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${track.title} ditambahkan ke antrian'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.remove_circle_outline_rounded,
                  color: cs.error),
              title: Text('Hapus dari Playlist',
                  style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<PlaylistProvider>()
                    .removeTrackFromPlaylist(playlistId, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
