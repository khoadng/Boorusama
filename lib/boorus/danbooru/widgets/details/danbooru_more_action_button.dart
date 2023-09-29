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
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
        width: 40,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          shape: const CircleBorder(),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'download':
                  showDownloadStartToast(context);
                  download(post);
                  break;
                case 'add_to_favgroup':
                  goToAddToFavoriteGroupSelectionPage(context, [post]);
                  break;
                case 'add_to_blacklist':
                  goToAddToBlacklistPage(context, post);
                  break;
                case 'add_to_global_blacklist':
                  goToAddToGlobalBlacklistPage(context, post.extractTags());
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
                // ignore: no_default_cases
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: const Text('download.download').tr(),
              ),
              if (booruConfig.hasLoginDetails())
                PopupMenuItem(
                  value: 'add_to_favgroup',
                  child: const Text('post.action.add_to_favorite_group').tr(),
                ),
              if (booruConfig.hasLoginDetails())
                PopupMenuItem(
                  value: 'add_to_blacklist',
                  child: const Text('post.detail.add_to_blacklist').tr(),
                ),
              const PopupMenuItem(
                value: 'add_to_global_blacklist',
                child: Text('Add to global blacklist'),
              ),
              PopupMenuItem(
                value: 'view_in_browser',
                child: const Text('post.detail.view_in_browser').tr(),
              ),
              if (post.hasFullView)
                PopupMenuItem(
                  value: 'view_original',
                  child: const Text('post.image_fullview.view_original').tr(),
                ),
              // const PopupMenuItem(
              //   value: 'toggle_slide_show',
              //   child: Text('Toggle slide show'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
