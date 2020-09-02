import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cache_image/constants.dart';
import 'package:cache_image/hive_cache_image.dart';
import 'package:cache_image/utils.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;



class CacheImageService{

  static final _cacheBox = Hive.box(Constants.HIVE_CACHE_IMAGE_BOX);
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);
  static final _storageInstance = fb.storage();
  static String _proxy;

  static void init({String proxy}){
    _proxy = proxy;
  }

  static Future<ui.Codec> fetchImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
    bool enableCache,
  ) async{
    Uint8List bytes;
    HiveCacheImage cacheImage = _getHiveImage(url);
    if(cacheImage == null){
      bytes = await _downloadImage(
        url,
        retryDuration,
        maxRetryDuration,
      );
      if(bytes.lengthInBytes != 0) {
        if(enableCache) _saveHiveImage(url, bytes);
      }
      else {
        /// TODO
        return null;
      }
    }
    else bytes = cacheImage.binaryImage;
    return ui.instantiateImageCodec(bytes);
  }

  static Future<Uint8List> _downloadImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
  ) async{
    int totalTime = 0;
    Uint8List bytes = Uint8List(0);
    Duration _retryDuration = Duration(microseconds: 1);
    if (Utils.isGsUrl(url)) url = await _getStandardUrlFromGsUrl(url);
    else if(_proxy != null) url = _proxy + url;
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

  static HiveCacheImage _getHiveImage(String url){
    String id = _stringToBase64.encode(url);
    if(!_cacheBox.containsKey(id)) return null;
    return _cacheBox.get(id);
  }

  static HiveCacheImage _saveHiveImage(String url, Uint8List image){
    String id = _stringToBase64.encode(url);
    HiveCacheImage cacheImage = HiveCacheImage(
      url: url,
      binaryImage: image,
    );
    _cacheBox.put(id, cacheImage);
    return cacheImage;
  }

  static Future<String> _getStandardUrlFromGsUrl(String gsUrl) async{
    return (await _storageInstance.refFromURL(gsUrl).getDownloadURL()).toString();
  }

}