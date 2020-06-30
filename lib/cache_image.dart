library cache_image;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/resource.dart';
import 'package:cache_image/cache_image_mobile.dart'
if(dart.library.html) 'package:cache_image/cache_image_web.dart';

/*
 *  ImageCache for Flutter
 *
 *  Copyright (c) 2019 Oxequa - Alessio Pracchia
 *  Keep in touch https://www.linkedin.com/in/alessio-pracchia/
 *
 *  Released under MIT License.
 */

class CacheImage extends ImageProvider<CacheImage> {
  CacheImage(
      String url, {
        this.scale = 1.0,
        this.cache = true,
        this.duration = const Duration(seconds: 1),
        this.durationMultiplier = 1.5,
        this.durationExpiration = const Duration(seconds: 10),
        this.inMemory = true,
      })  : assert(url != null),
        _resource =
        Resource(url, duration, durationMultiplier, durationExpiration),
        url = url;


  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Enable or disable image caching.
  final bool cache;

  /// Retry duration if download fails.
  final Duration duration;

  /// Retry duration multiplier.
  final double durationMultiplier;

  /// Retry duration expiration.
  final Duration durationExpiration;

  final String url;

  final bool inMemory;

  Resource _resource;

  @override
  Future<CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheImage key, DecoderCallback decode) {
    if(inMemory) return ImageManager.fetchImage(key);
    return MultiFrameImageStreamCompleter(
        codec: CacheImageService.fetchImage(_resource),
        scale: key.scale,
        informationCollector: () sync* {
          yield DiagnosticsProperty<ImageProvider>(
              'Image provider: $this \n Image key: $key', this,
              style: DiagnosticsTreeStyle.errorProperty);
        });
  }
}

class ImageManager{

  static HashMap<String, ImageStreamCompleter>  _manager = HashMap();

  static ImageStreamCompleter fetchImage(CacheImage key){
    if(_manager.containsKey(key.url)) return _manager[key.url];
    _manager[key.url] = MultiFrameImageStreamCompleter(
      codec: CacheImageService.fetchImage(key._resource),
      scale: key.scale,
    );
    return _manager[key.url];
  }

}
