// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruMoreActionButton extends ConsumerWidget {
  const DanbooruMoreActionButton({
    super.key,
    required this.post,
    this.onToggleSlideShow,
  });

  final DanbooruPost post;
  final VoidCallback? onToggleSlideShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;

    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
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
                    download(post);
                    break;
                  case 'add_to_favgroup':
                    goToAddToFavoriteGroupSelectionPage(context, [post]);
                    break;
                  case 'show_tag_list':
                    goToDanbooruShowTaglistPage(
                      ref,
                      post.extractTags(),
                    );
                    break;
                  case 'view_in_browser':
                    launchExternalUrl(
                      post.getUriLink(booruConfig.url),
                    );
                    break;
                  case 'view_original':
                    goToOriginalImagePage(context, post);
                    break;
                  case 'toggle_slide_show':
                    onToggleSlideShow?.call();
                    break;
                  case 'tag_history':
                    goToPostVersionPage(context, post);
                  // ignore: no_default_cases
                  default:
                }
              },
              itemBuilder: {
                'download': const Text('download.download').tr(),
                if (booruConfig.hasLoginDetails())
                  'add_to_favgroup':
                      const Text('post.action.add_to_favorite_group').tr(),
                'show_tag_list': const Text('View tags'),
                'tag_history': const Text('View tag history'),
                if (!booruConfig.hasStrictSFW)
                  'view_in_browser':
                      const Text('post.detail.view_in_browser').tr(),
                if (post.hasFullView)
                  'view_original':
                      const Text('post.image_fullview.view_original').tr(),
                // 'toggle_slide_show': const Text('Toggle slide show'),
              }),
        ),
      ),
    );
  }
}
