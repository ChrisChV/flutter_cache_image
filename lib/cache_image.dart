library cache_image;

import 'dart:async';
import 'dart:collection';
import 'package:cache_image/constants.dart';
import 'package:cache_image/hive_cache_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/cache_image_mobile.dart'
if(dart.library.html) 'package:cache_image/cache_image_web.dart';
import 'package:hive/hive.dart';


/// TODO En web activar el CORS en storage

class CacheImage extends ImageProvider<CacheImage> {
  CacheImage(
      this.url, {
        this.imageScale = Constants.DEFAULT_IMAGE_SCALE,
        this.enableCache = true,
        this.retryDuration = const Duration(seconds: Constants.DEFAULT_RETRY_DURATION),
        this.maxRetryDuration = const Duration(seconds: Constants.DEFAULT_MAX_RETRY_DURATION),
        this.enableInMemory = true,
      })  : assert(url != null);

  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double imageScale;

  /// Enable or disable image caching.
  final bool enableCache;

  /// Retry duration if download fails.
  final Duration retryDuration;

  /// Retry duration expiration.
  final Duration maxRetryDuration;

  final bool enableInMemory;

  static Future<void> init({String proxy}) async{
    CacheImageService.init(proxy: proxy);
    if(kIsWeb){
      Hive..registerAdapter(HiveCacheImageAdapter());
      if(!Hive.isBoxOpen(Constants.HIVE_CACHE_IMAGE_BOX)){
        await Hive.openBox(Constants.HIVE_CACHE_IMAGE_BOX);
      }
    }
  }

  @override
  Future<CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheImage key, DecoderCallback decode) {
    if(enableCache && enableInMemory) return ImageManager.fetchImage(key);
    return MultiFrameImageStreamCompleter(
      codec: CacheImageService.fetchImage(
        url,
        retryDuration,
        maxRetryDuration,
        enableCache
      ),
      scale: key.imageScale,
    );
  }

}

class ImageManager{

  static HashMap<String, ImageStreamCompleter>  _manager = HashMap();

  static ImageStreamCompleter fetchImage(CacheImage key){
    if(_manager.containsKey(key.url)) return _manager[key.url];
    _manager[key.url] = MultiFrameImageStreamCompleter(
      codec: CacheImageService.fetchImage(
        key.url,
        key.retryDuration,
        key.maxRetryDuration,
        key.enableCache,
      ),
      scale: key.imageScale,
    );
    return _manager[key.url];
  }

}
