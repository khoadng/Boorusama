// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';

final selectedViewTagQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

class ShowTagListPage extends ConsumerWidget {
  const ShowTagListPage({
    super.key,
    required this.tags,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
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
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final tag = items[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 4,
                    ),
                    title: Text(
                      tag.displayName,
                      style: TextStyle(
                        color: ref.getTagColor(
                          context,
                          tag.category.name,
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
                            break;
                          case 'add_to_global_blacklist':
                            onAddToGlobalBlacklist?.call(tag);
                            break;
                          case 'add_to_favorite_tags':
                            onAddToFavoriteTags?.call(tag);
                          case 'open_wiki':
                            onOpenWiki?.call(tag);
                          case 'copy':
                            Clipboard.setData(
                              ClipboardData(
                                text: tag.rawName,
                              ),
                            ).then(
                              (_) => showSimpleSnackBar(
                                context: context,
                                content: const Text('Copied'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            break;
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
