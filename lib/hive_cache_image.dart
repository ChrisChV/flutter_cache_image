import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'hive_cache_image.g.dart';

@HiveType(typeId: 7)
class HiveCacheImage{

  @HiveField(0)
  String gsUrl;

  @HiveField(1)
  String standardUrl;

  @HiveField(2)
  Uint8List binaryImage;

  HiveCacheImage({
    this.gsUrl,
    this.standardUrl,
    this.binaryImage,
  });

}