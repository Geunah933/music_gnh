import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/track.dart';

/// Manages locally uploaded music tracks stored in Hive.
class LocalMusicProvider extends ChangeNotifier {
  static const String _boxName = 'localMusicBox';
  List<Track> _tracks = [];
  bool _isLoaded = false;

  List<Track> get tracks => _tracks;
  bool get isLoaded => _isLoaded;
  int get trackCount => _tracks.length;

  LocalMusicProvider() {
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final box = await Hive.openBox<String>(_boxName);
    _tracks = [];
    for (int i = 0; i < box.length; i++) {
      final jsonStr = box.getAt(i);
      if (jsonStr != null) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          var track = Track.fromMap(map);

          // Auto-migrate absolute paths to relative paths
          String? localFilePath = track.localFilePath;
          String? localCoverPath = track.localCoverPath;
          bool updated = false;

          if (localFilePath != null && localFilePath.startsWith('/')) {
            final index = localFilePath.indexOf('/music/');
            if (index >= 0) {
              localFilePath = localFilePath.substring(index + 1);
              updated = true;
            }
          }
          if (localCoverPath != null && localCoverPath.startsWith('/')) {
            final index = localCoverPath.indexOf('/covers/');
            if (index >= 0) {
              localCoverPath = localCoverPath.substring(index + 1);
              updated = true;
            }
          }

          if (updated) {
            track = Track(
              spotifyId: track.spotifyId,
              title: track.title,
              artistName: track.artistName,
              albumName: track.albumName,
              albumArtUrl: track.albumArtUrl,
              previewUrl: track.previewUrl,
              localFilePath: localFilePath,
              localCoverPath: localCoverPath,
              youtubeVideoId: track.youtubeVideoId,
              lyrics: track.lyrics,
              year: track.year,
              durationMs: track.durationMs,
              isLocal: track.isLocal,
              cachedAt: track.cachedAt,
            );
            await box.putAt(i, jsonEncode(track.toMap()));
          }

          _tracks.add(track);
        } catch (e) {
          debugPrint('Error loading track at $i: $e');
        }
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns app music directory, creating it if needed.
  Future<String> get _musicDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${appDir.path}/music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir.path;
  }

  /// Returns app covers directory, creating it if needed.
  Future<String> get _coversDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory('${appDir.path}/covers');
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir.path;
  }

  /// Adds a new track from a local MP3 file.
  /// [sourceFilePath] - path to the picked MP3 file
  /// [coverFilePath] - optional path to the picked cover image
  /// [title], [artistName], [albumName] - metadata
  Future<Track> addTrack({
    required String sourceFilePath,
    String? coverFilePath,
    required String title,
    required String artistName,
    String albumName = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Copy MP3 to app directory
    final musicPath = await _musicDir;
    final ext = sourceFilePath.split('.').last;
    final destMusicPath = '$musicPath/$id.$ext';
    await File(sourceFilePath).copy(destMusicPath);

    // Copy cover image if provided
    String? destCoverPath;
    String? coverExt;
    if (coverFilePath != null) {
      final coversPath = await _coversDir;
      coverExt = coverFilePath.split('.').last;
      destCoverPath = '$coversPath/$id.$coverExt';
      await File(coverFilePath).copy(destCoverPath);
    }

    final relativeMusicPath = 'music/$id.$ext';
    final relativeCoverPath = coverFilePath != null ? 'covers/$id.$coverExt' : null;

    final track = Track.fromLocal(
      id: id,
      title: title,
      artistName: artistName,
      albumName: albumName,
      filePath: relativeMusicPath,
      coverPath: relativeCoverPath,
    );

    // Save to Hive
    final box = await Hive.openBox<String>(_boxName);
    await box.add(jsonEncode(track.toMap()));

    _tracks.add(track);
    notifyListeners();
    return track;
  }

  /// Removes a track and deletes its files.
  Future<void> removeTrack(int index) async {
    if (index < 0 || index >= _tracks.length) return;

    final track = _tracks[index];

    // Delete files
    if (track.absoluteFilePath != null) {
      final file = File(track.absoluteFilePath!);
      if (await file.exists()) await file.delete();
    }
    if (track.absoluteCoverPath != null) {
      final file = File(track.absoluteCoverPath!);
      if (await file.exists()) await file.delete();
    }

    // Remove from Hive
    final box = await Hive.openBox<String>(_boxName);
    await box.deleteAt(index);

    _tracks.removeAt(index);
    notifyListeners();
  }

  /// Updates track metadata.
  Future<void> updateTrack(int index, {
    String? title,
    String? artistName,
    String? albumName,
    String? newCoverPath,
  }) async {
    if (index < 0 || index >= _tracks.length) return;

    final old = _tracks[index];
    String? coverPath = old.localCoverPath;

    // Copy new cover if provided
    if (newCoverPath != null) {
      final coversPath = await _coversDir;
      final id = old.spotifyId.replaceFirst('local_', '');
      final coverExt = newCoverPath.split('.').last;
      final destCoverPath = '$coversPath/${id}_updated.$coverExt';
      await File(newCoverPath).copy(destCoverPath);
      coverPath = 'covers/${id}_updated.$coverExt';
    }

    final updated = Track.fromLocal(
      id: old.spotifyId.replaceFirst('local_', ''),
      title: title ?? old.title,
      artistName: artistName ?? old.artistName,
      albumName: albumName ?? old.albumName,
      filePath: old.localFilePath!,
      coverPath: coverPath,
      durationMs: old.durationMs,
    );

    _tracks[index] = updated;

    // Update Hive
    final box = await Hive.openBox<String>(_boxName);
    await box.putAt(index, jsonEncode(updated.toMap()));

    notifyListeners();
  }
}
