// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart' as ex;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../http/providers.dart';
import '../../images/providers.dart';
import 'types.dart';

final imagePreloadManagerProvider =
    Provider.family<
      ImagePreloadManager,
      ({Dio dio, BooruConfigAuth authConfig})
    >(
      (ref, params) {
        final cacheManager = ref.watch(defaultImageCacheManagerProvider);
        final imagePreloader = ex.ImagePreloader(
          cacheManager: cacheManager,
          dio: params.dio,
        );
        final headers = ref.watch(httpHeadersProvider(params.authConfig));

        final manager = ImagePreloadManager(
          preloader: (url, cancelToken) => imagePreloader.preloadImage(
            url,
            headers: headers,
            cancelToken: cancelToken,
          ),
          downloadConfiguration: const DownloadConfiguration(
            maxConcurrentDownloads: 2,
          ),
        );

        ref.onDispose(() {
          manager.dispose();
        });

        return manager;
      },
    );
