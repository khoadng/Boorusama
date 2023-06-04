// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/authentication/authentication.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/i18n.dart';

class DanbooruMoreActionButton extends ConsumerWidget {
  const DanbooruMoreActionButton({
    super.key,
    required this.post,
    required this.onToggleSlideShow,
  });

  final DanbooruPost post;
  final VoidCallback onToggleSlideShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);
    final authenticationState = ref.watch(authenticationProvider);

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
                  download(post);
                  break;
                case 'add_to_favgroup':
                  goToAddToFavoriteGroupSelectionPage(context, [post]);
                  break;
                case 'add_to_blacklist':
                  goToAddToBlacklistPage(context, post);
                  break;
                case 'view_in_browser':
                  launchExternalUrl(
                    post.getUriLink(booru.url),
                  );
                  break;
                case 'view_original':
                  goToOriginalImagePage(context, post);
                  break;
                case 'toggle_slide_show':
                  onToggleSlideShow();
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
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_favgroup',
                  child: Text('Add to favorite group'),
                ),
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_blacklist',
                  child: Text('Add to blacklist'),
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
