// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../../../core/tags/tag/widgets.dart';
import '../../../../../core/wikis/launcher.dart';
import '../../../blacklist/providers.dart';
import 'danbooru_tag_context_menu.dart';

class DanbooruShowTagListPage extends ConsumerWidget {
  const DanbooruShowTagListPage({
    required this.post,
    required this.initiallyMultiSelectEnabled,
    super.key,
  });

  final Post post;
  final bool initiallyMultiSelectEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final blacklistNotifier = ref.watch(
      danbooruBlacklistedTagsProvider(config).notifier,
    );

    return ShowTagListPage(
      post: post,
      auth: config,
      initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
      contextMenuBuilder: (child, tag) => DanbooruTagContextMenu(
        tag: tag,
        child: child,
      ),
      onOpenWiki: (tag) {
        launchWikiPage(
          config.url,
          tag.rawName,
        );
      },
      onAddToBlacklist: config.hasLoginDetails()
          ? (tag) {
              blacklistNotifier.addWithToast(
                context: ref.context,
                tag: tag.rawName,
              );
            }
          : null,
    );
  }
}
