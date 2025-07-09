// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/hydrus/client_provider.dart';
import '../boorus/booru/booru.dart';
import '../configs/config.dart';

final extraHttpHeaderProvider =
    Provider.family<Map<String, String>, BooruConfigAuth>(
      (ref, config) => switch (config.booruType) {
        //FIXME: don't reference the client provider here, it should be done somewhere else
        BooruType.hydrus =>
          ref.watch(hydrusClientProvider(config)).apiKeyHeader,
        _ => {},
      },
    );

final defaultCachedImageFileProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>(
      (ref, imageUrl) async {
        final cacheManager = DefaultImageCacheManager();
        final cacheKey = cacheManager.generateCacheKey(imageUrl);
        final bytes = await cacheManager.getCachedFileBytes(cacheKey);

        return bytes;
      },
    );
