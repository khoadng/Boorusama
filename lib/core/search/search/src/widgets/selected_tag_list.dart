// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../tags/favorites/providers.dart';
import '../../../../tags/tag/widgets.dart';
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
        '$extraTagsCount other${extraTagsCount! > 1 ? 's' : ''}',
    ];

    return BooruAnimatedCrossFade(
      firstChild: Row(
        children: [
          BooruPopupMenuButton(
            offset: const Offset(0, 40),
            onSelected: (value) {
              if (value == 0) {
                onClear.call();
              } else if (value == 1) {
                onBulkDownload(tags);
              }
            },
            itemBuilder: {
              0: const Text('search.remove_all_selected').tr(),
              1: const Text('sideMenu.bulk_download').tr(),
            },
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.75),
                                  ),
                                  Text(
                                    otherTagsCount,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
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

class SelectedTagContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
  const SelectedTagContextMenu({
    required this.tag,
    required this.child,
    super.key,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
          ContextMenuButtonConfig(
            'post.detail.add_to_favorites'.tr(),
            onPressed: () {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            },
          ),
        ],
      ),
      child: child,
    );
  }
}
