// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/blacklist/blacklist.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/tags/pages/show_tag_list_page.dart';
import 'package:boorusama/core/tags/tag/display.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/core/wikis/launcher.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';

class DanbooruShowTagListPage extends ConsumerWidget {
  const DanbooruShowTagListPage({
    super.key,
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final blacklistNotifier =
        ref.watch(danbooruBlacklistedTagsProvider(config).notifier);
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);
    final favoriteNotifier = ref.watch(favoriteTagsProvider.notifier);

    return ShowTagListPage(
      tags: tags,
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
      onAddToGlobalBlacklist: (tag) {
        globalNotifier.addTagWithToast(
          ref.context,
          tag.rawName,
        );
      },
      onAddToFavoriteTags: (tag) async {
        await favoriteNotifier.add(tag.rawName);

        if (!context.mounted) return;

        showSuccessToast(
          context,
          'Added',
          backgroundColor: context.colorScheme.onSurface,
          textStyle: TextStyle(
            color: context.colorScheme.surface,
          ),
        );
      },
    );
  }
}
