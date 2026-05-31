import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/database/hive_init.dart';
import '../models/playlist.dart';
import '../models/track.dart';

/// Manages playlist CRUD operations with Hive persistence.
class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

  PlaylistProvider() {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    try {
      final box = HiveInit.playlistsBox;
      _playlists = box.values.map((raw) {
        final map = Map<String, dynamic>.from(
          jsonDecode(raw) as Map,
        );
        return Playlist.fromMap(map);
      }).toList();
      // Sort by most recently updated
      _playlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final box = HiveInit.playlistsBox;
      await box.clear();
      for (final pl in _playlists) {
        await box.add(jsonEncode(pl.toMap()));
      }
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  /// Create a new empty playlist.
  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
    );
    _playlists.insert(0, playlist);
    await _savePlaylists();
    notifyListeners();
    return playlist;
  }

  /// Delete a playlist by ID.
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((pl) => pl.id == playlistId);
    await _savePlaylists();
    notifyListeners();
  }

  /// Rename a playlist.
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    pl.name = newName;
    pl.updatedAt = DateTime.now();
    await _savePlaylists();
    notifyListeners();
  }

  /// Add a track to a playlist.
  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    // Avoid duplicates
    final exists = pl.tracks.any((t) => t['spotifyId'] == track.spotifyId);
    if (exists) return;

    pl.tracks.add(track.toMap());
    pl.updatedAt = DateTime.now();
    await _savePlaylists();
    notifyListeners();
  }

  /// Remove a track from a playlist by index.
  Future<void> removeTrackFromPlaylist(String playlistId, int trackIndex) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (trackIndex >= 0 && trackIndex < pl.tracks.length) {
      pl.tracks.removeAt(trackIndex);
      pl.updatedAt = DateTime.now();
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// Get all tracks in a playlist as Track objects.
  List<Track> getPlaylistTracks(String playlistId) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    return pl.tracks.map((m) => Track.fromMap(m)).toList();
  }

  /// Reorder track within a playlist.
  Future<void> reorderTrack(String playlistId, int oldIndex, int newIndex) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (newIndex > oldIndex) newIndex--;
    final item = pl.tracks.removeAt(oldIndex);
    pl.tracks.insert(newIndex, item);
    pl.updatedAt = DateTime.now();
    await _savePlaylists();
    notifyListeners();
  }
}
