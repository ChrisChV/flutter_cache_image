library cache_image;

import 'dart:async';
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

  Resource _resource;

  @override
  Future<CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheImage key, DecoderCallback decode) {
    print("CACHE IMAAAAAAAAGEEEEEEE");
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
