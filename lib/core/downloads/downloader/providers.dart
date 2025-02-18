// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config.dart';
import '../urls/download_url.dart';
import 'background_downloader.dart';
import 'download_service.dart';

final downloadServiceProvider =
    Provider.family<DownloadService, BooruConfigAuth>(
  (ref, config) {
    return BackgroundDownloader();
  },
);

final downloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final downloadFileUrlExtractor = repo?.downloadFileUrlExtractor(config);

    if (downloadFileUrlExtractor != null) {
      return downloadFileUrlExtractor;
    }

    return const UrlInsidePostExtractor();
  },
);
