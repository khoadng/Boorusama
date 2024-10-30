// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class SelectedTagList extends StatelessWidget {
  const SelectedTagList({
    super.key,
    required this.tags,
    required this.onClear,
    required this.onDelete,
    required this.onUpdate,
    required this.onBulkDownload,
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
              1: const Text('download.bulk_download').tr(),
            },
          ),
          Expanded(
            child: SizedBox(
              height: 35,
              child: ListView.builder(
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
                                        .withOpacity(0.75),
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
                                              .withOpacity(0.5),
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
    super.key,
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
        ],
      ),
      child: child,
    );
  }
}
