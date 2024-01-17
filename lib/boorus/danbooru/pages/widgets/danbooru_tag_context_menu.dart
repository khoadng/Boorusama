// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruTagContextMenu extends ConsumerWidget {
  const DanbooruTagContextMenu({
    super.key,
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ContextMenu(
      items: [
        PopupMenuItem(
          value: 'add_to_search',
          child: Text('Add "$tag"'),
        ),
        PopupMenuItem(
          value: 'add_negated_to_search',
          child: Text('Add "-$tag"'),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Text('Copy tag'),
        ),
        PopupMenuItem(
          value: 'wiki',
          child: const Text('post.detail.open_wiki').tr(),
        ),
        PopupMenuItem(
          value: 'add_to_favorites',
          child: const Text('post.detail.add_to_favorites').tr(),
        ),
        if (config.hasLoginDetails())
          PopupMenuItem(
            value: 'blacklist',
            child: const Text('post.detail.add_to_blacklist').tr(),
          ),
        if (config.hasLoginDetails())
          PopupMenuItem(
            value: 'copy_and_move_to_saved_search',
            child: const Text(
              'post.detail.copy_and_open_saved_search',
            ).tr(),
          ),
      ],
      onSelected: (value) {
        if (value == 'blacklist') {
          ref
              .read(danbooruBlacklistedTagsProvider(config).notifier)
              .addWithToast(tag: tag);
        } else if (value == 'wiki') {
          launchWikiPage(config.url, tag);
        } else if (value == 'copy_and_move_to_saved_search') {
          Clipboard.setData(
            ClipboardData(text: tag),
          ).then((value) => goToSavedSearchEditPage(context));
        } else if (value == 'add_to_favorites') {
          ref.read(favoriteTagsProvider.notifier).add(tag);
        } else if (value == 'copy') {
          Clipboard.setData(
            ClipboardData(text: tag),
          ).then((value) => showSuccessToast('Copied'));
        } else if (value == 'add_to_search') {
          goToSearchPage(
            context,
            tag: tag,
            intent: SearchIntent.add,
          );
        } else if (value == 'add_negated_to_search') {
          goToSearchPage(
            context,
            tag: '-$tag',
            intent: SearchIntent.add,
          );
        }
      },
      child: child,
    );
  }
}
