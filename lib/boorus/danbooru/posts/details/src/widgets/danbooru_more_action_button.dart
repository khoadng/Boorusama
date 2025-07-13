// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/downloads/downloader/providers.dart';
import '../../../../../../core/images/copy.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/posts/post/providers.dart';
import '../../../../../../core/posts/post/routes.dart';
import '../../../../../../core/settings/routes.dart';
import '../../../../../../core/tags/tag/routes.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/url_launcher.dart';
import '../../../../versions/routes.dart';
import '../../../favgroups/favgroups/routes.dart';
import '../../../post/post.dart';

class DanbooruMoreActionButton extends ConsumerWidget with CopyImageMixin {
  const DanbooruMoreActionButton({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
    this.onStartSlideshow,
  });

  final DanbooruPost post;
  @override
  final BooruConfigAuth config;
  @override
  final BooruConfigViewer configViewer;
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
                ref.download(post);
              case 'copy_image':
                copyImage(ref, post);
              case 'add_to_favgroup':
                goToAddToFavoriteGroupSelectionPage(context, [post]);
              case 'show_tag_list':
                goToShowTaglistPage(ref, post);
              case 'view_in_browser':
                launchExternalUrlString(
                  postLinkGenerator.getLink(post),
                );
              case 'view_original':
                goToOriginalImagePage(ref, post);
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
              case 'tag_history':
                goToPostVersionPage(ref, post);
              case 'settings':
                openImageViewerSettingsPage(ref);
              default:
            }
          },
          itemBuilder: {
            'download': Text(context.t.download.download),
            'copy_image': Text('Copy image'.hc),
            if (config.hasLoginDetails())
              'add_to_favgroup': Text(
                context.t.post.action.add_to_favorite_group,
              ),
            if (post.tags.isNotEmpty) 'show_tag_list': Text('View tags'.hc),
            'tag_history': Text('View tag history'.hc),
            if (!config.hasStrictSFW)
              'view_in_browser': Text(context.t.post.detail.view_in_browser),
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
