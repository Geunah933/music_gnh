import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Splash screen that plays the opening video, then navigates to the main app.
class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  bool _videoInitialized = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    // Force full-screen immersive mode during splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Fade-out animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/opening.mp4');

    try {
      await _videoController.initialize();
      _videoController.setVolume(0.0); // Mute — splash is visual only
      _videoController.addListener(_onVideoProgress);

      if (mounted) {
        setState(() => _videoInitialized = true);
        _videoController.play();
      }
    } catch (e) {
      // If video fails to load, skip splash immediately
      debugPrint('Splash video error: $e');
      _goToApp();
    }
  }

  void _onVideoProgress() {
    if (_navigating) return;

    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    // When video is near the end or has finished, trigger transition
    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 300)) {
      _goToApp();
    }
  }

  Future<void> _goToApp() async {
    if (_navigating) return;
    _navigating = true;

    // Fade out the splash
    await _fadeController.forward();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.child,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoProgress);
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
        ),
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: _videoInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const SizedBox.shrink(), // Black screen while loading
        ),
      ),
    );
  }
}
