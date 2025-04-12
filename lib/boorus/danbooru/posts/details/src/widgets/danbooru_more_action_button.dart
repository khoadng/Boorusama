// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/boorus/engine/providers.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/downloads/downloader.dart';
import '../../../../../../core/foundation/url_launcher.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/posts/post/routes.dart';
import '../../../../../../core/settings/routes.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../tags/tag/routes.dart';
import '../../../../versions/routes.dart';
import '../../../favgroups/favgroups/routes.dart';
import '../../../post/post.dart';

class DanbooruMoreActionButton extends ConsumerWidget {
  const DanbooruMoreActionButton({
    required this.post,
    super.key,
    this.onStartSlideshow,
  });

  final DanbooruPost post;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final postLinkGenerator = ref.watch(currentPostLinkGeneratorProvider);

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
              case 'add_to_favgroup':
                goToAddToFavoriteGroupSelectionPage(context, [post]);
              case 'show_tag_list':
                goToDanbooruShowTaglistPage(
                  ref,
                  post.extractTags(),
                );
              case 'view_in_browser':
                if (postLinkGenerator == null) return;

                launchExternalUrlString(
                  postLinkGenerator.getLink(post),
                );
              case 'view_original':
                goToOriginalImagePage(context, post);
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
              case 'tag_history':
                goToPostVersionPage(context, post);
              case 'settings':
                openImageViewerSettingsPage(context);
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (booruConfig.hasLoginDetails())
              'add_to_favgroup':
                  const Text('post.action.add_to_favorite_group').tr(),
            if (post.tags.isNotEmpty) 'show_tag_list': const Text('View tags'),
            'tag_history': const Text('View tag history'),
            if (!booruConfig.hasStrictSFW && postLinkGenerator != null)
              'view_in_browser': const Text('post.detail.view_in_browser').tr(),
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
