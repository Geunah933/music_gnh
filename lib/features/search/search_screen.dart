import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/hive_init.dart';
import '../../models/search_result.dart';
import '../../models/track.dart';
import '../../providers/settings_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../services/deezer_service.dart';

/// Search screen with debounced music search, browse categories, and recent searches.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final settings = context.read<SettingsProvider>();
    final saveSearchHistory = settings.saveSearchHistory;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Deezer (free, no API key needed)
      final service = DeezerService();
      final results = await service.search(query);

      // Save to search history
      if (saveSearchHistory) {
        final box = HiveInit.searchHistoryBox;
        final existing = box.values.toList();
        if (existing.contains(query)) {
          final idx = existing.indexOf(query);
          await box.deleteAt(idx);
        }
        await box.add(query);
        while (box.length > 20) {
          await box.deleteAt(0);
        }
      }

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
          _hasSearched = true;
        });
      }
    }
  }

  void _onResultTap(SearchResult result) {
    if (result.type == SearchResultType.track && result.rawJson != null) {
      final track = result.source == 'deezer'
          ? Track.fromDeezerJson(result.rawJson!)
          : Track.fromSpotifyJson(result.rawJson!);

      // Build queue from all track results
      final trackResults = _results
          .where((r) => r.type == SearchResultType.track && r.rawJson != null)
          .map((r) => r.source == 'deezer'
              ? Track.fromDeezerJson(r.rawJson!)
              : Track.fromSpotifyJson(r.rawJson!))
          .toList();

      final audio = context.read<AudioPlayerProvider>();
      final idx = trackResults.indexWhere((t) => t.spotifyId == track.spotifyId);
      if (trackResults.isNotEmpty && idx >= 0) {
        audio.playAll(trackResults, startIndex: idx);
      } else {
        audio.playTrack(track);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final showResults =
        _searchController.text.isNotEmpty || _hasSearched;

    return CustomScrollView(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: l10n.whatDoYouWantToListenTo,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _focusNode.hasFocus
                      ? cs.primary
                      : cs.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Content
        if (showResults) ...[
          // Loading or Results
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: cs.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_results.isEmpty && _hasSearched)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noResults,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l10n.topResults,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final r = _results[index];
                return _SearchResultTile(
                  result: r,
                  onTap: () => _onResultTap(r),
                );
              },
            ),
          ],
        ] else ...[
          // Default view: Recent searches + Browse
          _buildRecentSearches(context),
          _buildBrowseCategories(context),
        ],

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final history = HiveInit.searchHistoryBox.values.toList().reversed.toList();

    if (history.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recentSearches,
              style: AppTextStyles.headlineMedium.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...history.take(5).map((query) => InkWell(
                  onTap: () {
                    _searchController.text = query;
                    _onSearchChanged(query);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            size: 22),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            query,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseCategories(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.browseAll,
              style: AppTextStyles.headlineMedium.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _CategoryTile(
                  title: cat['title']!,
                  icon: cat['icon']!,
                  color: Color(int.parse(cat['color']!.replaceFirst('#', '0xFF'))),
                  onTap: () {
                    _searchController.text = cat['title']!;
                    _onSearchChanged(cat['title']!);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _categories = [
    {'title': 'Pop', 'icon': '🎵', 'color': '#E13300'},
    {'title': 'Rock', 'icon': '🎸', 'color': '#E8115B'},
    {'title': 'Hip-Hop', 'icon': '🎤', 'color': '#BC5900'},
    {'title': 'Electronic', 'icon': '🎧', 'color': '#1E3264'},
    {'title': 'Jazz', 'icon': '🎷', 'color': '#777777'},
    {'title': 'R&B', 'icon': '💜', 'color': '#DC148C'},
    {'title': 'K-Pop', 'icon': '🇰🇷', 'color': '#5C27A0'},
    {'title': 'Reggaeton', 'icon': '🌴', 'color': '#0D7342'},
    {'title': 'Country', 'icon': '🤠', 'color': '#A05C27'},
    {'title': 'Classical', 'icon': '🎻', 'color': '#3D5A80'},
    {'title': 'Metal', 'icon': '🤘', 'color': '#2D2D2D'},
    {'title': 'Indie', 'icon': '🌿', 'color': '#4A7C59'},
  ];
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isArtist = result.type == SearchResultType.artist;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(isArtist ? 20 : 4),
                child: result.imageUrl != null && result.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: result.imageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        memCacheWidth: 120,
                        placeholder: (_, _) => Container(
                          width: 40,
                          height: 40,
                          color: cs.surfaceContainer,
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(isArtist ? 20 : 4),
                        ),
                        child: Icon(
                          isArtist
                              ? Icons.person_rounded
                              : Icons.music_note_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      result.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (result.type == SearchResultType.track)
                Icon(Icons.play_arrow_rounded,
                    color: cs.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
