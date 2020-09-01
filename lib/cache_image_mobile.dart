import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:cache_image/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/resource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CacheImageService {

  static String _tempPath;
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);

  static void init() async {
    _tempPath = (await getTemporaryDirectory()).path;
  }

  static Future<ui.Codec> fetchImage(Resource resource) async {
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

  static Future<ui.Codec> fetchImage2(
    String url, {
    Duration retryDuration =
                    const Duration(seconds: Constants.DEFAULT_RETRY_DURATION),
    Duration maxRetryDuration =
                    const Duration(seconds: Constants.DEFAULT_MAX_RETRY_DURATION),
  }) async{
    Uint8List bytes;
    String id = _stringToBase64.encode(url);
    String path = _tempPath + '/' + id;
    final File file = File(path);
    if (_fileIsCached(file)) bytes = file.readAsBytesSync();
    else {
      file.create(recursive: true);
      bytes = await _downloadImage(url, file, retryDuration, maxRetryDuration);
      if(bytes.lengthInBytes != 0) file.writeAsBytes(bytes);
      else{
        /// TODO
        return null;
      }
    }
    return PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  static bool _fileIsCached(File file){
    if (file.existsSync() && file.lengthSync() > 0) {
      return true;
    }
    return false;
  }

  static Future<Uint8List> _downloadImage(
    String url,
    File file,
    Duration retryDuration,
    Duration maxRetryDuration,
  ) async{
    int totalTime = 0;
    Duration _retryDuration = Duration(microseconds: 1);
    while(file.lengthSync() <= 0){
      await Future.delayed(_retryDuration).then((_) async{
        try{
          http.Response response = await http.get(url);
          return response.bodyBytes;
        }
        catch (error){
          _retryDuration = retryDuration;
          totalTime += retryDuration.inSeconds;
        }
      });
      if(totalTime > maxRetryDuration.inSeconds) break;
    }
    return Uint8List(0);
  }


}
