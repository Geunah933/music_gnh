import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/spotify_service.dart';
import '../../widgets/app_top_bar.dart';

/// Settings screen — Theme mode, language, cache, API keys.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _spotifyClientIdController = TextEditingController();
  final _spotifySecretController = TextEditingController();
  final _youtubeKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    if (settings.spotifyClientId.isNotEmpty) {
      _spotifyClientIdController.text = '••••••••••••••••';
    }
    if (settings.spotifyClientSecret.isNotEmpty) {
      _spotifySecretController.text = '••••••••••••••••';
    }
    if (settings.youtubeApiKey.isNotEmpty) {
      _youtubeKeyController.text = '••••••••••••••••';
    }
  }

  @override
  void dispose() {
    _spotifyClientIdController.dispose();
    _spotifySecretController.dispose();
    _youtubeKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppTopBar(
        showBackButton: true,
        title: 'MUSIC GNH',
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: cs.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
        children: [
          // Page title
          Text(
            l10n.advancedSettings,
            style: AppTextStyles.headlineLargeMobile.copyWith(
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsDescription,
            style: AppTextStyles.bodyLarge.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // ── UI SETTINGS ──
          _SectionHeader(title: l10n.uiSettings),
          _SettingsCard(
            children: [
              // Theme Mode
              _buildThemeModeSetting(cs, l10n),
              _divider(cs),
              // Language
              _buildLanguageSetting(cs, l10n),
            ],
          ),
          const SizedBox(height: 32),

          // ── DATA & API ──
          _SectionHeader(title: l10n.dataAndApi),
          _SettingsCard(
            children: [
              // Offline Mode
              _buildOfflineMode(cs, l10n),
              _divider(cs),
              // Cache Manager
              _buildCacheManager(cs, l10n),
              _divider(cs),
              // Spotify API
              _buildSpotifyApi(cs, l10n),
              _divider(cs),
              // YouTube API
              _buildYoutubeApi(cs, l10n),
            ],
          ),
          const SizedBox(height: 32),

          // ── PREFERENCES ──
          _SectionHeader(title: l10n.preferences),
          _SettingsCard(
            children: [
              _buildSearchHistoryToggle(cs, l10n),
              _divider(cs),
              _buildDefaultSearchFilter(cs, l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs) => Divider(
        color: cs.outlineVariant.withValues(alpha: 0.2),
        height: 1,
      );

  Widget _buildThemeModeSetting(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.dark_mode_rounded, color: cs.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.themeMode,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _getThemeModeLabel(themeProvider.themeMode, l10n),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ThemeModeChip(
                      label: l10n.light,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () =>
                          themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    _ThemeModeChip(
                      label: l10n.dark,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () =>
                          themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    _ThemeModeChip(
                      label: l10n.auto,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () =>
                          themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.auto;
    }
  }

  Widget _buildLanguageSetting(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.language_rounded, color: cs.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      localeProvider.locale.languageCode == 'id'
                          ? 'Bahasa Indonesia'
                          : 'English',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                underline: const SizedBox.shrink(),
                dropdownColor: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'id',
                    child: Text('Bahasa Indonesia'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    localeProvider.setLocale(Locale(value));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfflineMode(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          type: MaterialType.transparency,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            secondary: Icon(Icons.wifi_off_rounded, color: cs.onSurfaceVariant),
            title: Text(
              l10n.offlineMode,
              style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              l10n.forceLocalOnly,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            value: settings.offlineMode,
            onChanged: (v) => settings.setOfflineMode(v),
          ),
        );
      },
    );
  }

  Widget _buildCacheManager(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.storage_rounded, color: cs.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.localCache,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: settings.cacheSizeText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: cs.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' ${l10n.usedForArtworkAndMetadata}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await settings.clearAllCache();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.cacheCleared)),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
                  backgroundColor: cs.errorContainer.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.clearCache,
                  style: AppTextStyles.labelCaps.copyWith(color: cs.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpotifyApi(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.api_rounded, color: cs.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.spotifyApiConfiguration,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        if (settings.hasSpotifyCredentials)
                          Text(
                            '✓ Connected',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    // Client ID field
                    TextField(
                      controller: _spotifyClientIdController,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      onTap: () {
                        if (_spotifyClientIdController.text == '••••••••••••••••') {
                          _spotifyClientIdController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Client ID',
                        isDense: true,
                        filled: true,
                        fillColor: cs.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Client Secret field
                    TextField(
                      controller: _spotifySecretController,
                      obscureText: true,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      onTap: () {
                        if (_spotifySecretController.text == '••••••••••••••••') {
                          _spotifySecretController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Client Secret',
                        isDense: true,
                        filled: true,
                        fillColor: cs.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final clientId = _spotifyClientIdController.text.trim();
                          final clientSecret = _spotifySecretController.text.trim();
                          if (clientId.isEmpty || clientId == '••••••••••••••••' ||
                              clientSecret.isEmpty || clientSecret == '••••••••••••••••') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter both Client ID and Client Secret'),
                                backgroundColor: cs.error,
                              ),
                            );
                            return;
                          }
                          settings.setSpotifyCredentials(clientId, clientSecret);
                          _spotifyClientIdController.text = '••••••••••••••••';
                          _spotifySecretController.text = '••••••••••••••••';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Spotify API credentials saved! ✓'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(
                          l10n.saveKey,
                          style: AppTextStyles.labelCaps,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Test Connection button
                    if (settings.hasSpotifyCredentials)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Testing connection...')),
                            );
                            final service = SpotifyService(
                              clientId: settings.spotifyClientId,
                              clientSecret: settings.spotifyClientSecret,
                            );
                            final result = await service.testConnection();
                            messenger.hideCurrentSnackBar();
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Spotify Test'),
                                content: Text(result),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.wifi_find_rounded, size: 18),
                          label: const Text('TEST CONNECTION'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: cs.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYoutubeApi(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.play_circle_outline_rounded,
                      color: cs.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.youtubeApiConfiguration,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        if (settings.hasYoutubeKey)
                          Text(
                            '✓ Connected',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    TextField(
                      controller: _youtubeKeyController,
                      obscureText: true,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      onTap: () {
                        if (_youtubeKeyController.text == '••••••••••••••••') {
                          _youtubeKeyController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: l10n.enterApiKey,
                        isDense: true,
                        filled: true,
                        fillColor: cs.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final key = _youtubeKeyController.text.trim();
                          if (key.isEmpty || key == '••••••••••••••••') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.enterApiKey),
                                backgroundColor: cs.error,
                              ),
                            );
                            return;
                          }
                          settings.setYoutubeApiKey(key);
                          _youtubeKeyController.text = '••••••••••••••••';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('YouTube API key saved! ✓'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(
                          l10n.saveKey,
                          style: AppTextStyles.labelCaps,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchHistoryToggle(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          type: MaterialType.transparency,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            secondary:
                Icon(Icons.history_rounded, color: cs.onSurfaceVariant),
            title: Text(
              l10n.saveSearchHistory,
              style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              l10n.keepLocalLog,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            value: settings.saveSearchHistory,
            onChanged: (v) => settings.setSaveSearchHistory(v),
          ),
        );
      },
    );
  }

  Widget _buildDefaultSearchFilter(ColorScheme cs, AppLocalizations l10n) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.defaultSearchFilter,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: settings.defaultSearchFilter,
                underline: const SizedBox.shrink(),
                dropdownColor: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(l10n.globalAll),
                  ),
                  DropdownMenuItem(
                    value: 'artists',
                    child: Text(l10n.artists),
                  ),
                  DropdownMenuItem(
                    value: 'albums',
                    child: Text(l10n.albums),
                  ),
                  DropdownMenuItem(
                    value: 'tracks',
                    child: Text(l10n.tracks),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) settings.setDefaultSearchFilter(v);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(
          color: cs.primary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _ThemeModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
