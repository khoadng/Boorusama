// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../foundation/url_launcher.dart';
import '../configs/config.dart';
import '../downloads/downloader/providers.dart';
import '../images/copy.dart';
import '../posts/post/post.dart';
import '../posts/post/providers.dart';
import '../posts/post/routes.dart';
import '../settings/routes.dart';
import '../tags/tag/routes.dart';
import '../theme.dart';
import 'booru_popup_menu_button.dart';

class GeneralMoreActionButton extends ConsumerWidget with CopyImageMixin {
  const GeneralMoreActionButton({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
    this.onDownload,
    this.onStartSlideshow,
  });

  final Post post;
  @override
  final BooruConfigAuth config;
  @override
  final BooruConfigViewer configViewer;
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
              case 'copy_image':
                copyImage(ref, post);
              case 'view_in_browser':
                launchExternalUrlString(
                  postLinkGenerator.getLink(post),
                );
              case 'show_tag_list':
                goToShowTaglistPage(ref, post);
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
            'download': Text(context.t.download.download),
            'copy_image': Text('Copy image'.hc),
            if (!config.hasStrictSFW)
              'view_in_browser': Text(context.t.post.detail.view_in_browser),
            if (post.tags.isNotEmpty) 'show_tag_list': Text('View tags'.hc),
            if (post.hasFullView)
              'view_original': Text(
                context.t.post.image_fullview.view_original,
              ),
            if (onStartSlideshow != null)
              'start_slideshow': Text('Slideshow'.hc),
            'settings': Text(context.t.settings.settings),
          },
        ),
      ),
    );
  }
}
