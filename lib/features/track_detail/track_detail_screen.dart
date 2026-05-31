import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/hive_init.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../models/track.dart';
import '../../providers/settings_provider.dart';
import '../../services/youtube_service.dart';
import '../../services/lyrics_service.dart';
import '../../widgets/glassmorphic_card.dart';

/// Track detail screen — large album art, metadata, YouTube card, scrollable lyrics.
class TrackDetailScreen extends StatefulWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _loadingYoutube = true;
  bool _loadingLyrics = true;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Background fetch YouTube ID + Lyrics
    _fetchBackgroundData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _fetchBackgroundData() async {
    final settings = context.read<SettingsProvider>();

    // Run both in parallel
    await Future.wait([
      _fetchYoutubeId(settings),
      _fetchLyrics(),
    ]);

    // Save to Hive cache
    final box = HiveInit.tracksBox;
    await box.put(widget.track.spotifyId, widget.track);
  }

  Future<void> _fetchYoutubeId(SettingsProvider settings) async {
    if (widget.track.youtubeVideoId != null) {
      setState(() => _loadingYoutube = false);
      return;
    }

    if (!settings.hasYoutubeKey) {
      setState(() => _loadingYoutube = false);
      return;
    }

    try {
      final service = YoutubeService(apiKey: settings.youtubeApiKey);
      final videoId = await service.searchVideoId(
        trackName: widget.track.title,
        artistName: widget.track.artistName,
      );
      if (mounted) {
        setState(() {
          widget.track.youtubeVideoId = videoId;
          _loadingYoutube = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingYoutube = false);
    }
  }

  Future<void> _fetchLyrics() async {
    if (widget.track.lyrics != null) {
      setState(() => _loadingLyrics = false);
      return;
    }

    try {
      final lyrics = await LyricsService.fetchLyrics(
        artist: widget.track.artistName,
        title: widget.track.title,
      );
      if (mounted) {
        setState(() {
          widget.track.lyrics = lyrics;
          _loadingLyrics = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLyrics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: cs.surface.withValues(alpha: 0.7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'MUSIC GNH',
          style: AppTextStyles.headlineMedium.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ── Album Art with Ambient Glow ──
              _buildAlbumArt(cs),
              const SizedBox(height: 24),

              // ── Track Metadata ──
              _buildMetadata(cs),
              const SizedBox(height: 24),

              // ── YouTube Info Card ──
              _buildYoutubeCard(cs, l10n),
              const SizedBox(height: 24),

              // ── Lyrics Section ──
              _buildLyricsSection(cs, l10n, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(ColorScheme cs) {
    return Center(
      child: SizedBox(
        width: 340,
        height: 340,
        child: Stack(
          children: [
            // Ambient glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      colors: [
                        cs.secondary.withValues(alpha: _glowAnimation.value * 0.6),
                        cs.primary.withValues(alpha: _glowAnimation.value * 0.3),
                        cs.surface,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: _glowAnimation.value * 0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
            // Art image
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: widget.track.albumArtUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.track.albumArtUrl!,
                      width: 340,
                      height: 340,
                      fit: BoxFit.cover,
                      memCacheWidth: 680,
                    )
                  : Container(
                      width: 340,
                      height: 340,
                      color: cs.surfaceContainer,
                      child: Icon(
                        Icons.album_rounded,
                        size: 80,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.track.title,
                style: AppTextStyles.headlineLargeMobile.copyWith(
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.track.artistName} • ${widget.track.year ?? ''}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => _isLiked = !_isLiked);
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_isLiked),
              color: _isLiked ? cs.primary : cs.surfaceContainerHighest,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubeCard(ColorScheme cs, AppLocalizations l10n) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sourceVideo,
            style: AppTextStyles.labelCaps.copyWith(
              color: cs.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingYoutube)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.searchingYoutubeId,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Icon(Icons.smart_display_rounded,
                    color: cs.onSurfaceVariant, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      widget.track.youtubeVideoId ?? 'N/A',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.track.youtubeVideoId != null
                    ? () => UrlLauncherUtil.openYouTubeVideo(
                        widget.track.youtubeVideoId!)
                    : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.openInYoutube),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLyricsSection(
      ColorScheme cs, AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            l10n.lyrics,
            style: AppTextStyles.labelCaps.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: cs.surfaceContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: _loadingLyrics
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: cs.primary),
                      const SizedBox(height: 12),
                      Text(
                        l10n.searchingLyrics,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : widget.track.lyrics != null
                  ? ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.05, 0.9, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          widget.track.lyrics!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.8),
                            height: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        l10n.lyricsNotAvailable,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
