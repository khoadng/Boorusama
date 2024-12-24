// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../blacklists/providers.dart';
import '../../../../foundation/clipboard.dart';
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
