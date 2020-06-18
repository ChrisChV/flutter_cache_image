import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/resource.dart';

class CacheImageService {

  static Future<Codec> fetchImage(Resource resource) async {
    Uint8List file;
    await resource.init();
    final bool check = await resource.checkFile();
    if (check) {
      file = await resource.getFile();
    } else {
      file = await resource.storeFile();
    }
    if (file.length > 0) {
      return PaintingBinding.instance.instantiateImageCodec(file);
    }
    return null;
  }

}
