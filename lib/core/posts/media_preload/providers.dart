// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../http/client/providers.dart';
import '../../images/providers.dart';
import 'types.dart';

final preloadManagerProvider =
    Provider.family<PreloadManager, ({Dio dio, BooruConfigAuth authConfig})>(
      (ref, params) {
        final cacheManager = ref.watch(defaultImageCacheManagerProvider);
        final imagePreloader = ImagePreloader(
          cacheManager: cacheManager,
          dio: params.dio,
        );
        final headers = ref.watch(httpHeadersProvider(params.authConfig));

        final manager = PreloadManager(
          preloader: (url, cancelToken) => imagePreloader.preloadImage(
            url,
            headers: headers,
            cancelToken: cancelToken,
          ),
          downloadConfiguration: const DownloadConfiguration(),
        );

        ref.onDispose(() {
          manager.dispose();
        });

        return manager;
      },
    );
