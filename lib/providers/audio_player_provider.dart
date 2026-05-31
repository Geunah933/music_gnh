import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../models/track.dart';
import '../core/database/hive_init.dart';

/// Loop modes for the player.
enum PlayerRepeatMode { off, all, one }

/// Manages audio playback state, queue, and controls.
class AudioPlayerProvider extends ChangeNotifier {
  final ja.AudioPlayer _player = ja.AudioPlayer();

  List<Track> _queue = [];
  int _currentIndex = -1;
  bool _isShuffleOn = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  List<int> _shuffleOrder = [];
  bool _isLoadingTrack = false;
  List<Track> _recentlyPlayed = [];

  AudioPlayerProvider() {
    _loadRecentlyPlayed();

    _player.playerStateStream.listen((state) {
      notifyListeners();
    });

    _player.positionStream.listen((_) {
      notifyListeners();
    });

    _player.processingStateStream.listen((state) {
      if (state == ja.ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  List<Track> get recentlyPlayed => _recentlyPlayed;

  void _loadRecentlyPlayed() {
    try {
      final box = HiveInit.recentlyPlayedBox;
      _recentlyPlayed = box.values.toList();
    } catch (e) {
      debugPrint('Error loading recently played tracks: $e');
    }
  }

  void _addToRecentlyPlayed(Track track) async {
    _recentlyPlayed.removeWhere((t) => t.spotifyId == track.spotifyId);
    _recentlyPlayed.add(track);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed.removeAt(0);
    }
    notifyListeners();
    try {
      final box = HiveInit.recentlyPlayedBox;
      await box.clear();
      await box.addAll(_recentlyPlayed);
    } catch (e) {
      debugPrint('Error saving recently played tracks: $e');
    }
  }

  // ── Getters ──

  ja.AudioPlayer get player => _player;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isShuffleOn => _isShuffleOn;
  PlayerRepeatMode get repeatMode => _repeatMode;

  Track? get currentTrack =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;

  bool get isPlaying => _player.playing;
  bool get hasTrack => currentTrack != null;
  bool get isLoadingTrack => _isLoadingTrack;

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  bool get hasNext {
    if (_queue.isEmpty) return false;
    if (_repeatMode == PlayerRepeatMode.all) return true;
    if (_isShuffleOn) {
      final idx = _shuffleOrder.indexOf(_currentIndex);
      return idx < _shuffleOrder.length - 1;
    }
    return _currentIndex < _queue.length - 1;
  }

  bool get hasPrevious {
    if (_queue.isEmpty) return false;
    if (_repeatMode == PlayerRepeatMode.all) return true;
    if (_isShuffleOn) {
      final idx = _shuffleOrder.indexOf(_currentIndex);
      return idx > 0;
    }
    return _currentIndex > 0;
  }

  // ── Playback Controls ──

  Future<void> playTrack(Track track) async {
    final existingIdx = _queue.indexWhere((t) => t.spotifyId == track.spotifyId);
    if (existingIdx >= 0) {
      _currentIndex = existingIdx;
    } else {
      _queue.add(track);
      _currentIndex = _queue.length - 1;
      _regenerateShuffleOrder();
    }
    await _loadAndPlay();
  }

  Future<void> playAll(List<Track> tracks, {int startIndex = 0}) async {
    _queue = List.from(tracks);
    _currentIndex = startIndex;
    _regenerateShuffleOrder();
    await _loadAndPlay();
  }

  void addToQueue(Track track) {
    _queue.add(track);
    _regenerateShuffleOrder();
    notifyListeners();
  }

  Future<void> _loadAndPlay() async {
    final track = currentTrack;
    if (track == null) return;

    _isLoadingTrack = true;
    notifyListeners();

    // Determine audio source: local file or network URL
    String? audioSource = track.absoluteFilePath ?? track.previewUrl;

    if (audioSource == null || audioSource.isEmpty) {
      debugPrint('No audio source for: ${track.title}');
      _isLoadingTrack = false;
      notifyListeners();
      // DON'T auto-skip — just stop and show error state
      return;
    }

    try {
      if (track.absoluteFilePath != null) {
        // Local file
        await _player.setFilePath(track.absoluteFilePath!);
      } else {
        // Network URL (Deezer preview)
        await _player.setUrl(audioSource);
      }
      _isLoadingTrack = false;
      await _player.play();
      _addToRecentlyPlayed(track);
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
      _isLoadingTrack = false;
      notifyListeners();
      // DON'T auto-skip — just stop
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffleOn) {
      final idx = _shuffleOrder.indexOf(_currentIndex);
      if (idx < _shuffleOrder.length - 1) {
        _currentIndex = _shuffleOrder[idx + 1];
      } else if (_repeatMode == PlayerRepeatMode.all) {
        _regenerateShuffleOrder();
        _currentIndex = _shuffleOrder.first;
      } else {
        return;
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = 0;
      } else {
        return;
      }
    }
    await _loadAndPlay();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_isShuffleOn) {
      final idx = _shuffleOrder.indexOf(_currentIndex);
      if (idx > 0) {
        _currentIndex = _shuffleOrder[idx - 1];
      } else if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = _shuffleOrder.last;
      } else {
        return;
      }
    } else {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        return;
      }
    }
    await _loadAndPlay();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToProgress(double value) async {
    final pos = Duration(
      milliseconds: (duration.inMilliseconds * value).round(),
    );
    await _player.seek(pos);
  }

  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) _regenerateShuffleOrder();
    notifyListeners();
  }

  void togglePlayerRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (_queue.isEmpty) {
      _currentIndex = -1;
      _player.stop();
    } else if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
      _loadAndPlay();
    }
    _regenerateShuffleOrder();
    notifyListeners();
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _player.stop();
    notifyListeners();
  }

  // ── Private ──

  void _onTrackCompleted() {
    if (_repeatMode == PlayerRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }
    next();
  }

  void _regenerateShuffleOrder() {
    _shuffleOrder = List.generate(_queue.length, (i) => i);
    _shuffleOrder.shuffle(Random());
    if (_currentIndex >= 0 && _shuffleOrder.contains(_currentIndex)) {
      _shuffleOrder.remove(_currentIndex);
      _shuffleOrder.insert(0, _currentIndex);
    }
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
