// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/downloads/filename/types.dart';
import '../../../core/posts/post/types.dart';
import '../tags/providers.dart';

final animePicturesDownloadFilenameGeneratorProvider =
    Provider.family<DownloadFilenameGenerator, BooruConfigAuth>((ref, config) {
      return DownloadFileNameBuilder<Post>(
        defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        sampleData: kDanbooruPostSamples,
        hasRating: false,
        extensionHandler: (post, config) => post.format.startsWith('.')
            ? post.format.substring(1)
            : post.format,
        tokenHandlers: [
          WidthTokenHandler(),
          HeightTokenHandler(),
          AspectRatioTokenHandler(),
        ],
        asyncTokenHandlers: [
          AsyncTokenHandler(
            ClassicTagsTokenResolver(
              tagExtractor: ref.watch(
                animePicturesTagExtractorProvider(config),
              ),
            ),
          ),
        ],
      );
    });
