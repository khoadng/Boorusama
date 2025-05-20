// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../configs/config.dart';
import '../../../../foundation/clipboard.dart';
import '../../../../search/search/routes.dart';
import '../../../../search/search/widgets.dart';
import '../tag.dart';
import '../tag_display.dart';
import '../tag_providers.dart';
import '../widgets/filterable_scope.dart';

final selectedViewTagQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

class ShowTagListPage extends ConsumerWidget {
  const ShowTagListPage({
    required this.tags,
    required this.auth,
    super.key,
    this.onAddToBlacklist,
    this.onAddToGlobalBlacklist,
    this.onAddToFavoriteTags,
    this.onOpenWiki,
  });

  final List<Tag> tags;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;
  final void Function(Tag tag)? onOpenWiki;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Symbols.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('Tags'),
      ),
      body: FilterableScope(
        originalItems: tags,
        query: ref.watch(selectedViewTagQueryProvider),
        filter: (item, query) => item.rawName.contains(query),
        builder: (context, items) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BooruSearchBar(
                hintText: 'Filter...',
                onChanged: (value) => ref
                    .read(selectedViewTagQueryProvider.notifier)
                    .state = value,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final tag = items[index];

                  return ListTile(
                    minTileHeight: 12,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 4,
                    ),
                    title: Text(
                      tag.displayName,
                      style: TextStyle(
                        color: ref.watch(
                          tagColorProvider(
                            (auth, tag.category.name),
                          ),
                        ),
                      ),
                    ),
                    onTap: () => goToSearchPage(
                      context,
                      tag: tag.rawName,
                    ),
                    trailing: BooruPopupMenuButton(
                      onSelected: (value) {
                        switch (value) {
                          case 'add_to_blacklist':
                            onAddToBlacklist?.call(tag);
                          case 'add_to_global_blacklist':
                            onAddToGlobalBlacklist?.call(tag);
                          case 'add_to_favorite_tags':
                            onAddToFavoriteTags?.call(tag);
                          case 'open_wiki':
                            onOpenWiki?.call(tag);
                          case 'copy':
                            AppClipboard.copyWithDefaultToast(
                              context,
                              tag.rawName,
                            );
                        }
                      },
                      itemBuilder: {
                        'copy': const Text('Copy'),
                        if (onAddToBlacklist != null)
                          'add_to_blacklist':
                              const Text('post.detail.add_to_blacklist').tr(),
                        'add_to_global_blacklist':
                            const Text('Add to global blacklist'),
                        'add_to_favorite_tags': const Text('Add to favorites'),
                        if (onOpenWiki != null)
                          'open_wiki': const Text('post.detail.open_wiki').tr(),
                      },
                    ),
                  );
                },
                itemCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
