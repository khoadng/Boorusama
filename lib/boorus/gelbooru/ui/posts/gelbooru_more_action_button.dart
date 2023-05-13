// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/utils.dart';

class GelbooruMoreActionButton extends ConsumerWidget {
  const GelbooruMoreActionButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

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
                case 'add_to_bookmark':
                  ref.bookmarks.addBookmarkWithToast(
                    post.sampleImageUrl,
                    booru,
                    post,
                  );
                  break;
                case 'view_in_browser':
                  launchExternalUrl(
                    post.getUriLink(booru.url),
                  );
                  break;
                case 'view_original':
                  goToOriginalImagePage(context, post);
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
              const PopupMenuItem(
                value: 'add_to_bookmark',
                child: Text('Add to Bookmark'),
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
            ],
          ),
        ),
      ),
    );
  }
}
