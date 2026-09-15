// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/downloads/urls/types.dart';
import '../../../core/posts/post/types.dart';
import '../client_provider.dart';
import 'file_url_extractor.dart';

final zerochanDownloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>((ref, config) {
      return ZerochanDownloadFileUrlExtractor(
        client: ref.watch(zerochanClientProvider(config)),
      );
    });

final class ZerochanDownloadSource implements DownloadSourceProvider {
  const ZerochanDownloadSource();

  @override
  List<DownloadSource> getDownloadSources(BuildContext context, Post post) => [
    DownloadSource.quality(
      quality: 'preview',
      name: context.t.settings.download.qualities.preview,
    ),
    DownloadSource.quality(
      quality: 'sample',
      name: context.t.settings.download.qualities.sample,
    ),
    DownloadSource.quality(
      quality: 'original',
      name: context.t.settings.download.qualities.original,
    ),
  ];
}
