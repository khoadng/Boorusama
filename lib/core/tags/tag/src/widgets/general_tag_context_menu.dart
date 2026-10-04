// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../blacklists/providers.dart';
import '../../../../search/search/routes.dart';
import '../../../favorites/providers.dart';

class GeneralTagContextMenu extends ConsumerWidget
    with TagContextMenuItemsMixin {
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

    return KurumiContextMenu(
      menuItemsBuilder: (_) => [
        copyButton(context, tag),
        searchButton(ref, tag),
        KurumiContextMenuTile(
          title: context.t.post.detail.add_to_favorites,
          onTap: () {
            ref.read(favoriteTagsProvider.notifier).add(tag);
          },
        ),
        KurumiContextMenuTile(
          title: context.t.tags.actions.add_to_blacklist_global,
          onTap: () {
            globalNotifier.addTagWithToast(context, tag);
          },
        ),
        for (final entry in itemBindings.entries)
          KurumiContextMenuTile(
            title: entry.key,
            onTap: entry.value,
          ),
      ],
      child: child,
    );
  }
}

mixin TagContextMenuItemsMixin {
  Widget copyButton(BuildContext context, String tag) => KurumiContextMenuTile(
    title: context.t.tags.actions.copy_single,
    onTap: () {
      AppClipboard.copyAndToast(
        context,
        tag,
        message: context.t.generic.copied,
      );
    },
  );

  Widget searchButton(WidgetRef ref, String tag) => KurumiContextMenuTile(
    title: ref.context.t.tags.actions.search_single,
    onTap: () {
      goToSearchPage(ref, tag: tag);
    },
  );
}
