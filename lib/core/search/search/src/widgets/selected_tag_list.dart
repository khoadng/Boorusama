// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../tags/favorites/providers.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../../widgets/booru_context_menu.dart';
import '../../../../widgets/context_menu_tile.dart';
import '../../../../widgets/widgets.dart';
import '../../../selected_tags/tag_search_item.dart';
import 'selected_tag_chip.dart';

class SelectedTagList extends StatelessWidget {
  const SelectedTagList({
    required this.tags,
    required this.onClear,
    required this.onDelete,
    required this.onUpdate,
    required this.onBulkDownload,
    super.key,
    this.extraTagsCount,
    this.onOtherTagsCountTap,
  });

  final List<TagSearchItem> tags;
  final VoidCallback onClear;
  final void Function(TagSearchItem tag) onDelete;
  final void Function(TagSearchItem oldTag, String newTag)? onUpdate;
  final void Function(List<TagSearchItem> tags) onBulkDownload;
  final int? extraTagsCount;
  final void Function()? onOtherTagsCountTap;

  @override
  Widget build(BuildContext context) {
    final tagItems = [
      ...tags,
      if (extraTagsCount != null && extraTagsCount! > 0)
        context.t.tags.other_counter(
          n: extraTagsCount!,
        ),
    ];

    return BooruAnimatedCrossFade(
      firstChild: Row(
        children: [
          BooruPopupMenuButton(
            maxWidth: 250,
            items: [
              BooruPopupMenuItem(
                title: Text(context.t.search.remove_all_selected),
                icon: const Icon(Symbols.clear_all),
                onTap: onClear,
              ),
              BooruPopupMenuItem(
                title: Text(context.t.sideMenu.bulk_download),
                icon: const Icon(Symbols.download),
                onTap: () => onBulkDownload(tags),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 35,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: tagItems.length,
                itemBuilder: (context, index) {
                  final it = tagItems[index];

                  return switch (it) {
                    final TagSearchItem item => Builder(
                      builder: (context) {
                        final chip = SelectedTagChip(
                          tagSearchItem: item,
                          onDeleted: () => onDelete(item),
                          onUpdated: (tag) => onUpdate?.call(item, tag),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: item.isRaw
                              ? SelectedTagContextMenu(
                                  tag: item.toString(),
                                  child: chip,
                                )
                              : GeneralTagContextMenu(
                                  tag: item.rawTag,
                                  child: chip,
                                ),
                        );
                      },
                    ),
                    final String otherTagsCount => Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          onTap: onOtherTagsCountTap,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.add,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.75),
                                ),
                                Text(
                                  otherTagsCount,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        letterSpacing: 0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _ => Text('Unknown type: ${it.runtimeType}'),
                  };
                },
              ),
            ),
          ),
        ],
      ),
      secondChild: const SizedBox.shrink(),
      crossFadeState: tags.isNotEmpty
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(
        milliseconds: 100,
      ),
    );
  }
}

class SelectedTagContextMenu extends ConsumerWidget {
  const SelectedTagContextMenu({
    required this.tag,
    required this.child,
    super.key,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        CopyTagContextMenuTile(tag: tag),
        ContextMenuTile(
          title: context.t.post.detail.add_to_favorites,
          onTap: () {
            ref.read(favoriteTagsProvider.notifier).add(tag, isRaw: true);
          },
        ),
      ],
      child: child,
    );
  }
}
