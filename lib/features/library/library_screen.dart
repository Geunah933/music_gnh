import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/track.dart';
import '../../models/playlist.dart';
import '../../providers/local_music_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/track_cover_art.dart';
import '../upload/upload_music_screen.dart';
import 'playlist_detail_screen.dart';

/// Library screen with tabs: My Music (uploaded), Playlists, Artists.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Tab Bar + Upload Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              _TabButton(
                label: '🎵 My Music',
                isSelected: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              const SizedBox(width: 24),
              _TabButton(
                label: '📋 ${l10n.playlists}',
                isSelected: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
              const Spacer(),
              // Upload button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_rounded, color: cs.onPrimary, size: 20),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const UploadMusicScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MyMusicTab(),
              _PlaylistsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.headlineMedium.copyWith(
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Tab showing locally uploaded music.
class _MyMusicTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<LocalMusicProvider>(
      builder: (context, localMusic, _) {
        if (!localMusic.isLoaded) {
          return Center(
            child: CircularProgressIndicator(color: cs.primary),
          );
        }

        if (localMusic.tracks.isEmpty) {
          return _EmptyMyMusic(cs: cs);
        }

        return Column(
          children: [
            // Play All header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${localMusic.trackCount} lagu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      context.read<AudioPlayerProvider>().playAll(
                            localMusic.tracks,
                          );
                    },
                    icon: Icon(Icons.play_circle_filled_rounded,
                        color: cs.primary, size: 24),
                    label: Text('Play All',
                        style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
            ),
            // Track list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: localMusic.tracks.length,
                itemBuilder: (context, index) {
                  final track = localMusic.tracks[index];
                  return _LocalTrackTile(
                    track: track,
                    index: index,
                    onTap: () {
                      context.read<AudioPlayerProvider>().playAll(
                            localMusic.tracks,
                            startIndex: index,
                          );
                    },
                    onDelete: () => _confirmDelete(context, localMusic, index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, LocalMusicProvider provider, int index) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Hapus Lagu?', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Lagu "${provider.tracks[index].title}" akan dihapus secara permanen.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              provider.removeTrack(index);
              Navigator.pop(ctx);
            },
            child: Text('Hapus', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyMyMusic extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyMyMusic({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.library_music_rounded,
                  size: 56, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Lagu',
              style: AppTextStyles.headlineMedium.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + di atas untuk upload\nlagu MP3 dari device Anda',
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const UploadMusicScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload Lagu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalTrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LocalTrackTile({
    required this.track,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audio = context.watch<AudioPlayerProvider>();
    final isPlaying = audio.currentTrack?.spotifyId == track.spotifyId;

    return Material(
      color: isPlaying ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Cover art
              TrackCoverArt(
                track: track,
                size: 52,
                borderRadius: 8,
              ),
              const SizedBox(width: 12),
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isPlaying ? cs.primary : cs.onSurface,
                        fontWeight:
                            isPlaying ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${track.artistName} • ${track.albumName}',
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
              // Playing indicator or delete
              if (isPlaying)
                Icon(Icons.equalizer_rounded, color: cs.primary, size: 22)
              else
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
                onTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.queue_music_rounded,
                  color: cs.onSurfaceVariant),
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
              leading: Icon(Icons.playlist_add_rounded,
                  color: cs.onSurfaceVariant),
              title: Text('Tambah ke Playlist',
                  style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddToPlaylistDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: cs.error),
              title: Text('Hapus', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<PlaylistProvider>();
    final playlists = provider.playlists;

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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tambah ke Playlist',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
            // Create new playlist option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_rounded, color: cs.primary),
              ),
              title: Text('Buat Playlist Baru',
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final name = await _showCreatePlaylistDialog(context);
                if (name != null && name.isNotEmpty && context.mounted) {
                  final pl = await provider.createPlaylist(name);
                  await provider.addTrackToPlaylist(pl.id, track);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${track.title} ditambahkan ke "$name"'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                }
              },
            ),
            if (playlists.isNotEmpty) Divider(color: cs.outlineVariant),
            // Existing playlists
            ...playlists.map((pl) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: pl.coverArtUrl != null
                        ? CachedNetworkImage(
                            imageUrl: pl.coverArtUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            memCacheWidth: 120,
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.queue_music_rounded,
                                color: cs.onSurfaceVariant, size: 20),
                          ),
                  ),
                  title: Text(pl.name,
                      style: TextStyle(color: cs.onSurface)),
                  subtitle: Text('${pl.trackCount} lagu',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await provider.addTrackToPlaylist(pl.id, track);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${track.title} ditambahkan ke "${pl.name}"'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<String?> _showCreatePlaylistDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Playlist Baru', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Nama playlist',
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Buat', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final playlists = provider.playlists;

        if (playlists.isEmpty) {
          return _EmptyPlaylists(cs: cs);
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${playlists.length} playlist',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showCreateDialog(context, provider),
                    icon: Icon(Icons.add_rounded, color: cs.primary, size: 20),
                    label: Text('Buat Baru',
                        style: TextStyle(color: cs.primary, fontSize: 13)),
                  ),
                ],
              ),
            ),
            // Playlist grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final pl = playlists[index];
                  return _PlaylistCard(
                    playlist: pl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaylistDetailScreen(playlistId: pl.id),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _showPlaylistOptions(context, provider, pl),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, PlaylistProvider provider) async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Playlist Baru', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Nama playlist',
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Buat', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await provider.createPlaylist(name);
    }
  }

  void _showPlaylistOptions(
      BuildContext context, PlaylistProvider provider, Playlist pl) {
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                pl.name,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow_rounded, color: cs.primary),
              title: Text('Putar Semua', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                final tracks = provider.getPlaylistTracks(pl.id);
                if (tracks.isNotEmpty) {
                  context.read<AudioPlayerProvider>().playAll(tracks);
                }
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.edit_rounded, color: cs.onSurfaceVariant),
              title: Text('Ubah Nama', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, provider, pl);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: cs.error),
              title: Text('Hapus Playlist', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, provider, pl);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, PlaylistProvider provider, Playlist pl) async {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: pl.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Ubah Nama', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Nama baru',
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Simpan', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await provider.renamePlaylist(pl.id, newName);
    }
  }

  void _confirmDelete(
      BuildContext context, PlaylistProvider provider, Playlist pl) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Hapus Playlist?', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Playlist "${pl.name}" akan dihapus secara permanen.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlaylist(pl.id);
              Navigator.pop(ctx);
            },
            child: Text('Hapus', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaylists extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyPlaylists({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.queue_music_rounded,
                  size: 56, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Playlist',
              style: AppTextStyles.headlineMedium.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buat playlist untuk mengatur\nlagu-lagu favorit Anda',
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final cs2 = Theme.of(context).colorScheme;
                final controller = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cs2.surfaceContainer,
                    title: Text('Playlist Baru',
                        style: TextStyle(color: cs2.onSurface)),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      style: TextStyle(color: cs2.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Nama playlist',
                        hintStyle: TextStyle(color: cs2.onSurfaceVariant),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Batal',
                            style: TextStyle(color: cs2.onSurfaceVariant)),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text.trim()),
                        child:
                            Text('Buat', style: TextStyle(color: cs2.primary)),
                      ),
                    ],
                  ),
                );
                if (name != null && name.isNotEmpty && context.mounted) {
                  context.read<PlaylistProvider>().createPlaylist(name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: playlist.coverArtUrl != null
                    ? CachedNetworkImage(
                        imageUrl: playlist.coverArtUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        placeholder: (_, _) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.queue_music_rounded,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                              size: 40),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.queue_music_rounded,
                          color: cs.primary.withValues(alpha: 0.3),
                          size: 48,
                        ),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${playlist.trackCount} lagu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
