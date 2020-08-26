import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cache_image/constants.dart';
import 'package:cache_image/hive_cache_image.dart';
import 'package:cache_image/resource.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CacheImageService{

  static final _cacheBox = Hive.box(Constants.HIVE_CACHE_IMAGE_BOX);
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);
  static final _storageInstance = fb.storage();

  static Future<ui.Codec> fetchImage(Resource resource) async{
    HiveCacheImage cacheImage = _getHiveImage(resource.uri);
    Uri standardUrl;
    Uint8List bytes;
    if(cacheImage == null){
      standardUrl = await _storageInstance.refFromURL(resource.uri).getDownloadURL();
      bytes = await _downloadImage(standardUrl);
      _saveHiveImage(resource.uri, standardUrl.toString(), bytes);
    }
    else{
      if(cacheImage.binaryImage != null){
        standardUrl = Uri.parse(cacheImage.standardUrl);
        bytes = await _downloadImage(standardUrl);
        _saveHiveImage(resource.uri, standardUrl.toString(), bytes);
      }
      else bytes = cacheImage.binaryImage;
    }
    return ui.instantiateImageCodec(bytes);
    /*return ui.webOnlyInstantiateImageCodecFromUrl(
        standardUrl
    ) as Future<ui.Codec>;
    
     */
  }

  static Future<Uint8List> _downloadImage(Uri standardUrl) async{
    HttpClient httpClient = new HttpClient();
    final HttpClientRequest request = await httpClient.getUrl(standardUrl);
    final HttpClientResponse response = await request.close();
    return await consolidateHttpClientResponseBytes(
        response,
        autoUncompress: false
    );
  }

  static HiveCacheImage _getHiveImage(String gsUrl){
    String id = _stringToBase64.encode(gsUrl);
    if(!_cacheBox.containsKey(id)) return null;
    return _cacheBox.get(id);
  }

  static HiveCacheImage _saveHiveImage(String gsUrl, String standardUrl, Uint8List image){
    String id = _stringToBase64.encode(gsUrl);
    HiveCacheImage cacheImage = HiveCacheImage(
      gsUrl: gsUrl,
      standardUrl: standardUrl,
      binaryImage: image,
    );
    _cacheBox.put(id, cacheImage);
    return cacheImage;
  }
}