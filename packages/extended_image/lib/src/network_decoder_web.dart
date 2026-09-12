import 'package:flutter/painting.dart';

import 'dio_extended_image_provider.dart';

/// Web uses Flutter's browser-backed image decoder, including for AVIF.
/// The native libavif decoder must not enter the web import graph.
ImageProvider networkImageDecoder({
  required DioExtendedNetworkImageProvider source,
  required bool useAvif,
  int? cacheWidth,
  int? cacheHeight,
}) => source;
