// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/posts/post/tags.dart';
import 'package:boorusama/core/settings/pages.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class GeneralMoreActionButton extends ConsumerWidget {
  const GeneralMoreActionButton({
    super.key,
    required this.post,
    this.onDownload,
    this.onStartSlideshow,
  });

  final Post post;
  final void Function(Post post)? onDownload;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watchConfigAuth;

    return SizedBox(
      width: 40,
      child: Material(
        color: context.extendedColorScheme.surfaceContainerOverlay,
        shape: const CircleBorder(),
        child: BooruPopupMenuButton(
          iconColor: context.extendedColorScheme.onSurfaceContainerOverlay,
          onSelected: (value) {
            switch (value) {
              case 'download':
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
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
                break;
              case 'settings':
                openImageViewerSettingsPage(context);
                break;
              // ignore: no_default_cases
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (!booru.hasStrictSFW)
              'view_in_browser': const Text('post.detail.view_in_browser').tr(),
            if (post.tags.isNotEmpty) 'show_tag_list': const Text('View tags'),
            if (post.hasFullView)
              'view_original':
                  const Text('post.image_fullview.view_original').tr(),
            if (onStartSlideshow != null)
              'start_slideshow': const Text('Slideshow'),
            'settings': const Text('settings.settings').tr(),
          },
        ),
      ),
    );
  }
}
