// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../analytics/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../http/client/providers.dart';
import '../../../../settings/providers.dart';
import '../../../filename/providers.dart';
import '../../../urls/providers.dart';
import '../data/providers.dart';
import 'download_notifier.dart';

final downloadNotifierParamsProvider =
    Provider.family<
      DownloadNotifierParams,
      (BooruConfigAuth, BooruConfigDownload)
    >(
      (ref, params) {
        final (auth, download) = params;
        return (
          download: download,
          downloadFileUrlExtractor: ref.watch(
            downloadFileUrlExtractorProvider(auth),
          ),
          observer: ref.watch(
            analyticsDownloadObserverProvider(auth),
          ),
          filenameBuilder: ref.watch(
            downloadFilenameBuilderProvider(auth),
          ),
          canDownloadMultipleFiles: ref.watch(
            downloadMultipleFileCheckProvider(auth),
          ),
          headers: ref.watch(
            httpHeadersProvider(auth),
          ),
          settings: ref.watch(settingsProvider),
          downloader: ref.watch(downloadServiceProvider),
          logger: ref.watch(loggerProvider),
        );
      },
    );
