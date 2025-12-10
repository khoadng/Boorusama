// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/downloads/urls/types.dart';
import '../../../core/posts/post/types.dart';
import '../posts/types.dart';

final class PhilomenaDownloadSource implements DownloadSourceProvider {
  const PhilomenaDownloadSource();

  @override
  List<DownloadSource> getDownloadSources(BuildContext context, Post post) {
    if (post case final PhilomenaPost philPost) {
      final rep = philPost.representation;
      return [
        if (rep.thumbTiny.isNotEmpty)
          DownloadSource(
            url: rep.thumbTiny,
            name: 'Thumb Tiny',
          ),
        if (rep.thumbSmall.isNotEmpty)
          DownloadSource(
            url: rep.thumbSmall,
            name: 'Thumb Small',
          ),
        if (rep.thumb.isNotEmpty)
          DownloadSource(
            url: rep.thumb,
            name: 'Thumb',
          ),
        if (rep.small.isNotEmpty)
          DownloadSource(
            url: rep.small,
            name: 'Small',
          ),
        if (rep.medium.isNotEmpty)
          DownloadSource(
            url: rep.medium,
            name: 'Medium',
          ),
        if (rep.tall.isNotEmpty)
          DownloadSource(
            url: rep.tall,
            name: 'Tall',
          ),
        if (rep.large.isNotEmpty)
          DownloadSource(
            url: rep.large,
            name: context.t.settings.download.qualities.large,
          ),
        if (rep.full.isNotEmpty)
          DownloadSource(
            url: rep.full,
            name: context.t.settings.download.qualities.original,
          ),
      ];
    }

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
