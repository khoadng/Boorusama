// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/config.dart';
import '../downloads/downloader.dart';
import '../foundation/url_launcher.dart';
import '../posts/post/post.dart';
import '../posts/post/routes.dart';
import '../posts/post/tags.dart';
import '../settings/routes.dart';
import '../tags/tag/routes.dart';
import '../theme.dart';
import 'booru_popup_menu_button.dart';

class GeneralMoreActionButton extends ConsumerWidget {
  const GeneralMoreActionButton({
    required this.post,
    required this.config,
    super.key,
    this.onDownload,
    this.onStartSlideshow,
  });

  final Post post;
  final BooruConfigAuth config;
  final void Function(Post post)? onDownload;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(config));

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
              case 'view_in_browser':
                launchExternalUrlString(
                  postLinkGenerator.getLink(post),
                );
              case 'show_tag_list':
                goToShowTaglistPage(
                  context,
                  post.extractTags(),
                );
              case 'view_original':
                goToOriginalImagePage(ref, post);
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
              case 'settings':
                openImageViewerSettingsPage(ref);
              // ignore: no_default_cases
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (!config.hasStrictSFW)
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
