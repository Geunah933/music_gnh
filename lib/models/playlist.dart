/// Playlist model — stores a list of track spotifyIds + metadata.
class Playlist {
  final String id;
  String name;
  String? description;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Map<String, dynamic>> tracks;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? tracks,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tracks = tracks ?? [];

  int get trackCount => tracks.length;

  /// Total duration in milliseconds.
  int get totalDurationMs {
    int total = 0;
    for (final t in tracks) {
      total += (t['durationMs'] as int?) ?? 0;
    }
    return total;
  }

  String get totalDurationFormatted {
    final totalMin = (totalDurationMs / 60000).floor();
    if (totalMin < 60) return '$totalMin min';
    final hours = totalMin ~/ 60;
    final mins = totalMin % 60;
    return '${hours}h ${mins}m';
  }

  /// Cover art URL from the first track that has one.
  String? get coverArtUrl {
    for (final t in tracks) {
      final url = t['albumArtUrl'] as String?;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tracks': tracks,
      };

  factory Playlist.fromMap(Map<String, dynamic> map) => Playlist(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
        tracks: (map['tracks'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
      );
}
