// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';

class GeneralTagContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
  const GeneralTagContextMenu({
    super.key,
    this.itemBindings = const {},
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;
  final Map<String, void Function()> itemBindings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
          searchButton(context, tag),
          ContextMenuButtonConfig(
            'post.detail.add_to_favorites'.tr(),
            onPressed: () {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            },
          ),
          ContextMenuButtonConfig(
            'Add to global blacklist',
            onPressed: () {
              globalNotifier.addTagWithToast(context, tag);
            },
          ),
          for (final entry in itemBindings.entries)
            ContextMenuButtonConfig(
              entry.key,
              onPressed: entry.value,
            ),
        ],
      ),
      child: child,
    );
  }
}

mixin TagContextMenuButtonConfigMixin {
  ContextMenuButtonConfig copyButton(BuildContext context, String tag) =>
      ContextMenuButtonConfig(
        'Copy',
        onPressed: () {
          AppClipboard.copyAndToast(
            context,
            tag,
            message: 'post.detail.copied'.tr(),
          );
        },
      );

  ContextMenuButtonConfig searchButton(BuildContext context, String tag) =>
      ContextMenuButtonConfig(
        'Search',
        onPressed: () {
          goToSearchPage(context, tag: tag);
        },
      );
}
