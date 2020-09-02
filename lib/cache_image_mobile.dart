import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:cache_image/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CacheImageService {

  static String _tempPath;
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);

  static void init({String proxy}) async {
    _tempPath = (await getTemporaryDirectory()).path;
  }

  static Future<ui.Codec> fetchImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
    bool enableCache,
  ) async{
    Uint8List bytes;
    String id = _stringToBase64.encode(url);
    String path = _tempPath + '/' + id;
    final File file = File(path);
    if (_fileIsCached(file)) bytes = file.readAsBytesSync();
    else {
      bytes = await _downloadImage(url, retryDuration, maxRetryDuration);
      if(bytes.lengthInBytes != 0) {
        if(enableCache){
          file.create(recursive: true);
          file.writeAsBytes(bytes);
        }
      }
      else{
        /// TODO
        return null;
      }
    }
    return PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  static Future<Uint8List> _downloadImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
  ) async{
    int totalTime = 0;
    Uint8List bytes = Uint8List(0);
    Duration _retryDuration = Duration(microseconds: 1);
    if(Utils.isGsUrl(url)) url = await _getStandardUrlFromGsUrl(url);
    while(totalTime <= maxRetryDuration.inSeconds && bytes.lengthInBytes <= 0){
      await Future.delayed(_retryDuration).then((_) async{
        try{
          http.Response response = await http.get(url);
          bytes = response.bodyBytes;
        }
        catch (error){
          _retryDuration = retryDuration;
          totalTime += retryDuration.inSeconds;
        }
      });
    }
    return bytes;
  }

  static Future<dynamic> _getStandardUrlFromGsUrl(String gsUrl) async{
    Uri uri = Uri.parse(gsUrl);
    return FirebaseStorage.instance.ref().child(uri.path).getDownloadURL();
  }

  static bool _fileIsCached(File file){
    if (file.existsSync() && file.lengthSync() > 0) {
      return true;
    }
    return false;
  }

}
