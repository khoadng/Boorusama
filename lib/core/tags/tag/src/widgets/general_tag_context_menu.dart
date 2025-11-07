// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../blacklists/providers.dart';
import '../../../../search/search/routes.dart';
import '../../../../widgets/booru_context_menu.dart';
import '../../../../widgets/context_menu_tile.dart';
import '../../../favorites/providers.dart';

class GeneralTagContextMenu extends ConsumerWidget {
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

    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        CopyTagContextMenuTile(tag: tag),
        SearchTagContextMenuTile(tag: tag),
        AddToFavContextMenuTile(tag: tag),
        ContextMenuTile(
          title: context.t.tags.actions.add_to_blacklist_global,
          onTap: () {
            globalNotifier.addTagWithToast(context, tag);
          },
        ),
        for (final entry in itemBindings.entries)
          ContextMenuTile(
            title: entry.key,
            onTap: entry.value,
          ),
      ],
      child: child,
    );
  }
}

class AddToFavContextMenuTile extends ConsumerWidget {
  const AddToFavContextMenuTile({
    super.key,
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenuTile(
      title: context.t.post.detail.add_to_favorites,
      onTap: () {
        ref.read(favoriteTagsProvider.notifier).add(tag);
      },
    );
  }
}

class CopyTagContextMenuTile extends StatelessWidget {
  const CopyTagContextMenuTile({
    super.key,
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    return ContextMenuTile(
      title: context.t.tags.actions.copy_single,
      onTap: () {
        AppClipboard.copyAndToast(
          context,
          tag,
          message: context.t.generic.copied,
        );
      },
    );
  }
}

class SearchTagContextMenuTile extends ConsumerWidget {
  const SearchTagContextMenuTile({
    super.key,
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenuTile(
      title: context.t.tags.actions.search_single,
      onTap: () {
        goToSearchPage(ref, tag: tag);
      },
    );
  }
}
