// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/downloads/filename/types.dart';
import '../posts/types.dart';
import '../tag_summary/repo.dart';
import '../tags/providers.dart';

final moebooruDownloadFilenameGeneratorProvider =
    Provider.family<DownloadFilenameGenerator, BooruConfigAuth>((ref, config) {
      return DownloadFileNameBuilder<MoebooruPost>(
        defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        sampleData: kDanbooruPostSamples,
        preload: (posts, config, cancelToken) async {
          await ref
              .read(moebooruTagSummaryRepoProvider(config))
              .getTagSummaries();
        },
        tokenHandlers: [
          WidthTokenHandler(),
          HeightTokenHandler(),
          AspectRatioTokenHandler(),
          MPixelsTokenHandler(),
        ],
        asyncTokenHandlers: [
          AsyncTokenHandler(
            ClassicTagsTokenResolver(
              tagExtractor: ref.watch(moebooruTagExtractorProvider(config)),
            ),
          ),
        ],
      );
    });
