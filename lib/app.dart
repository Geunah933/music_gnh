import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/library/library_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/app_top_bar.dart';
import 'features/splash/splash_screen.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/mini_player_bar.dart';

/// Root MaterialApp with theme, locale, and tab navigation.
class MusicGnhApp extends StatelessWidget {
  const MusicGnhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          title: 'MUSIC GNH',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(child: _MainShell()),
        );
      },
    );
  }
}

/// Main shell widget that hosts the bottom navigation and page views.
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppTopBar(
        title: 'MUSIC GNH',
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: const [
          HomeScreen(),
          SearchScreen(),
          LibraryScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          AppBottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
