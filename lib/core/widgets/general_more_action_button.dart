// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class GeneralMoreActionButton extends ConsumerWidget {
  const GeneralMoreActionButton({
    super.key,
    required this.post,
    this.onDownload,
  });

  final Post post;
  final void Function(Post post)? onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watchConfig;

    return SizedBox(
      width: 40,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        child: BooruPopupMenuButton(
          iconColor: Colors.white,
          onSelected: (value) {
            switch (value) {
              case 'download':
                showDownloadStartToast(context);
                if (onDownload != null) {
                  onDownload!(post);
                } else {
                  ref.download(post);
                }
                break;
              case 'view_in_browser':
                launchExternalUrl(
                  post.getUriLink(booru.url),
                );
                break;
              case 'show_tag_list':
                goToShowTaglistPage(
                  ref,
                  post.extractTags(),
                );
                break;
              case 'view_original':
                goToOriginalImagePage(context, post);
                break;
              // ignore: no_default_cases
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (!booru.hasStrictSFW)
              'view_in_browser': const Text('post.detail.view_in_browser').tr(),
            'show_tag_list': const Text('View tags'),
            if (post.hasFullView)
              'view_original':
                  const Text('post.image_fullview.view_original').tr(),
          },
        ),
      ),
    );
  }
}
