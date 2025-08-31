// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../blacklists/providers.dart';
import '../../../../search/search/routes.dart';
import '../../../favorites/providers.dart';

class GeneralTagContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
  const GeneralTagContextMenu({
    required this.tag,
    required this.child,
    super.key,
    this.itemBindings = const {},
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
          searchButton(ref, tag),
          ContextMenuButtonConfig(
            context.t.post.detail.add_to_favorites,
            onPressed: () {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            },
          ),
          ContextMenuButtonConfig(
            context.t.tags.actions.add_to_blacklist_global,
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
        context.t.tags.actions.copy_single,
        onPressed: () {
          AppClipboard.copyAndToast(
            context,
            tag,
            message: context.t.generic.copied,
          );
        },
      );

  ContextMenuButtonConfig searchButton(WidgetRef ref, String tag) =>
      ContextMenuButtonConfig(
        ref.context.t.tags.actions.search_single,
        onPressed: () {
          goToSearchPage(ref, tag: tag);
        },
      );
}
