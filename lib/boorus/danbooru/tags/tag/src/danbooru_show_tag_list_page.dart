// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/tags/show/widgets.dart';
import '../../../../../core/tags/tag/types.dart';
import '../../../blacklist/providers.dart';
import '../../../configs/providers.dart';
import '../../../wikis/types.dart';
import 'danbooru_tag_context_menu.dart';

class DanbooruShowTagListPage extends ConsumerWidget {
  const DanbooruShowTagListPage({
    required this.auth,
    required this.post,
    required this.initiallyMultiSelectEnabled,
    super.key,
  });

  final BooruConfigAuth auth;
  final Post post;
  final bool initiallyMultiSelectEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistNotifier = ref.watch(
      danbooruBlacklistedTagsProvider(auth).notifier,
    );
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(auth));

    return ShowTagListPage(
      post: post,
      auth: auth,
      initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
      contextMenuBuilder: (child, tag) => DanbooruTagContextMenu(
        tag: tag,
        child: child,
      ),
      onOpenWiki: (tag) {
        launchWikiPage(
          auth.url,
          tag.rawName,
        );
      },
      onAddToBlacklist: loginDetails.hasLogin()
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
