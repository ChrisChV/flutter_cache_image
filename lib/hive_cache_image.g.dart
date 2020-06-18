// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_cache_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCacheImageAdapter extends TypeAdapter<HiveCacheImage> {
  @override
  final typeId = 7;

  @override
  HiveCacheImage read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCacheImage(
      gsUrl: fields[0] as String,
      standardUrl: fields[1] as String,
      binaryImage: fields[2] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCacheImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gsUrl)
      ..writeByte(1)
      ..write(obj.standardUrl)
      ..writeByte(2)
      ..write(obj.binaryImage);
  }
}
