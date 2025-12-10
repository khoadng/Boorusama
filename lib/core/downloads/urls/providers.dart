// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import '../../posts/post/types.dart';
import 'types.dart';

final downloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final downloadFileUrlExtractor = repo?.downloadFileUrlExtractor(config);

        if (downloadFileUrlExtractor != null) {
          return downloadFileUrlExtractor;
        }

        return const UrlInsidePostExtractor();
      },
    );

final downloadSourceProvider =
    Provider.family<DownloadSourceProvider?, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final downloadSourceProvider = repo?.downloadSource(config);

        return downloadSourceProvider;
      },
    );

final class DefaultDownloadSource implements DownloadSourceProvider {
  const DefaultDownloadSource();

  @override
  List<DownloadSource> getDownloadSources(BuildContext context, Post post) {
    return [
      if (post.thumbnailImageUrl.isNotEmpty)
        DownloadSource(
          url: post.thumbnailImageUrl,
          name: context.t.settings.download.qualities.preview,
        ),
      if (post.sampleImageUrl.isNotEmpty)
        DownloadSource(
          url: post.sampleImageUrl,
          name: context.t.settings.download.qualities.sample,
        ),
      if (post.originalImageUrl.isNotEmpty)
        DownloadSource(
          url: post.originalImageUrl,
          name: context.t.settings.download.qualities.original,
        ),
    ];
  }
}

final class UrlInsidePostExtractor implements DownloadFileUrlExtractor {
  const UrlInsidePostExtractor();

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) async {
    if (post.isVideo) return DownloadUrlData.urlOnly(post.videoUrl);

    final urls = [
      post.originalImageUrl,
      post.sampleImageUrl,
      post.thumbnailImageUrl,
    ];

    final url = switch (quality) {
      'original' => urls.firstWhereOrNull((e) => e.isNotEmpty),
      'sample' => urls.skip(1).firstWhereOrNull((e) => e.isNotEmpty),
      'preview' => post.thumbnailImageUrl,
      _ => urls.firstWhereOrNull((e) => e.isNotEmpty),
    };

    return url != null ? DownloadUrlData.urlOnly(url) : null;
  }
}
