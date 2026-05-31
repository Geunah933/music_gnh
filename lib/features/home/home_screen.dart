import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/track.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/track_cover_art.dart';

/// Home screen — greeting, trending tracks, recently played.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> _trendingTracks = [];
  List<Map<String, dynamic>> _topArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Fetch Deezer chart (trending tracks)
      final chartResponse = await http.get(
        Uri.parse('https://api.deezer.com/chart/0/tracks?limit=20'),
      );

      if (chartResponse.statusCode == 200) {
        final data = jsonDecode(chartResponse.body) as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        _trendingTracks = items
            .map((item) => Track.fromDeezerJson(item as Map<String, dynamic>))
            .toList();
      }

      // Fetch top artists
      final artistResponse = await http.get(
        Uri.parse('https://api.deezer.com/chart/0/artists?limit=10'),
      );

      if (artistResponse.statusCode == 200) {
        final data = jsonDecode(artistResponse.body) as Map<String, dynamic>;
        _topArtists = ((data['data'] as List<dynamic>?) ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading home content: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _loadContent();
      },
      color: cs.primary,
      child: CustomScrollView(
        slivers: [
          // ── Greeting ──
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withValues(alpha: 0.12),
                    cs.surface,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _getGreeting(l10n),
                style: AppTextStyles.headlineLargeMobile.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
          ),

          // ── Recently Played (from queue) ──
          _buildRecentlyPlayed(cs),

          // ── Top Artists horizontal scroll ──
          if (_topArtists.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  '🎤 Top Artists',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _topArtists.length,
                  itemBuilder: (context, index) {
                    final artist = _topArtists[index];
                    return _buildArtistChip(cs, artist);
                  },
                ),
              ),
            ),
          ],

          // ── Trending Tracks ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(
                    '🔥 Trending Now',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (_trendingTracks.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        final audio = context.read<AudioPlayerProvider>();
                        audio.playAll(_trendingTracks);
                      },
                      child: Text(
                        'Play All ▶',
                        style: TextStyle(color: cs.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: cs.primary),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: _trendingTracks.length,
              itemBuilder: (context, index) {
                final track = _trendingTracks[index];
                return _buildTrackTile(cs, track, index);
              },
            ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed(ColorScheme cs) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audio, _) {
        final recentTracks = audio.recentlyPlayed.reversed.take(6).toList();
        if (recentTracks.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  '🕐 Recently Played',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3.2,
                  ),
                  itemCount: recentTracks.length,
                  itemBuilder: (context, index) {
                    final track = recentTracks[index];
                    return Material(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          final audio = context.read<AudioPlayerProvider>();
                          audio.playTrack(track);
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomLeft: Radius.circular(6),
                              ),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: TrackCoverArt(
                                  track: track,
                                  size: 56,
                                  borderRadius: 0,
                                  memCacheWidth: 150,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                track.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistChip(ColorScheme cs, Map<String, dynamic> artist) {
    final name = artist['name'] as String? ?? '';
    final picture = artist['picture_medium'] as String? ??
        artist['picture'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage:
                  picture != null ? CachedNetworkImageProvider(picture) : null,
              child: picture == null
                  ? Icon(Icons.person, color: cs.onSurfaceVariant)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(ColorScheme cs, Track track, int index) {
    final audio = context.read<AudioPlayerProvider>();
    final isCurrentTrack = audio.currentTrack?.spotifyId == track.spotifyId;

    return Material(
      color: isCurrentTrack
          ? cs.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          audio.playAll(_trendingTracks, startIndex: index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              // Index number
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isCurrentTrack ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // Album art
              TrackCoverArt(
                track: track,
                size: 48,
                borderRadius: 6,
                memCacheWidth: 144,
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
                        color: isCurrentTrack ? cs.primary : cs.onSurface,
                        fontWeight:
                            isCurrentTrack ? FontWeight.w700 : FontWeight.w500,
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
              const SizedBox(width: 4),
              // Play indicator
              if (isCurrentTrack)
                Icon(Icons.equalizer_rounded, color: cs.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
