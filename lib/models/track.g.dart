// GENERATED CODE - Manually written TypeAdapter (no build_runner needed)

import 'package:hive/hive.dart';
import 'track.dart';

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 0;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      spotifyId: fields[0] as String,
      title: fields[1] as String,
      artistName: fields[2] as String,
      albumName: fields[3] as String,
      albumArtUrl: fields[4] as String?,
      youtubeVideoId: fields[5] as String?,
      lyrics: fields[6] as String?,
      year: fields[7] as String?,
      durationMs: fields[8] as int?,
      cachedAt: fields[9] as DateTime,
      localFilePath: fields[10] as String?,
      localCoverPath: fields[11] as String?,
      isLocal: (fields[12] as bool?) ?? false,
      previewUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(14) // number of fields
      ..writeByte(0)
      ..write(obj.spotifyId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.albumName)
      ..writeByte(4)
      ..write(obj.albumArtUrl)
      ..writeByte(5)
      ..write(obj.youtubeVideoId)
      ..writeByte(6)
      ..write(obj.lyrics)
      ..writeByte(7)
      ..write(obj.year)
      ..writeByte(8)
      ..write(obj.durationMs)
      ..writeByte(9)
      ..write(obj.cachedAt)
      ..writeByte(10)
      ..write(obj.localFilePath)
      ..writeByte(11)
      ..write(obj.localCoverPath)
      ..writeByte(12)
      ..write(obj.isLocal)
      ..writeByte(13)
      ..write(obj.previewUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
