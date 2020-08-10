import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cache_image/hive_cache_image.dart';
import 'package:cache_image/resource.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:hive/hive.dart';

class CacheImageService{

  static final _cacheBox = Hive.box('cache_image');
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);
  static final _storageInstance = fb.storage();

  static Future<ui.Codec> fetchImage(Resource resource) async{
    HiveCacheImage cacheImage = _getHiveImage(resource.uri);
    String url = 'https://cors-anywhere.herokuapp.com/';
    if(cacheImage == null){
      String imageUrl = (await _storageInstance.refFromURL(resource.uri).getDownloadURL()).toString();
      url += imageUrl;
      cacheImage = _saveHiveImage(resource.uri, imageUrl);
    }
    else url += cacheImage.standardUrl;
    Uri standardUrl = Uri.parse(url);
    print("AAAA");
    print(standardUrl.toString());
    return ui.webOnlyInstantiateImageCodecFromUrl(
        standardUrl
    ) as Future<ui.Codec>;
  }

  static HiveCacheImage _getHiveImage(String gsUrl){
    String id = _stringToBase64.encode(gsUrl);
    if(!_cacheBox.containsKey(id)) return null;
    return _cacheBox.get(id);
  }

  static HiveCacheImage _saveHiveImage(String gsUrl, String standardUrl){
    String id = _stringToBase64.encode(gsUrl);
    HiveCacheImage cacheImage = HiveCacheImage(
      gsUrl: gsUrl,
      standardUrl: standardUrl,
    );
    _cacheBox.put(id, cacheImage);
    return cacheImage;
  }
}