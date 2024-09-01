// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  final List<TagSearchItem> tags;
  final VoidCallback onClear;
  final void Function(TagSearchItem tag) onDelete;
  final void Function(TagSearchItem oldTag, String newTag)? onUpdate;
  final void Function(List<TagSearchItem> tags) onBulkDownload;

  @override
  Widget build(BuildContext context) {
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
            child: _SelectedTagChips(
              tags: tags,
              onDelete: onDelete,
              onUpdate: onUpdate,
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

class _SelectedTagChips extends StatelessWidget {
  const _SelectedTagChips({
    required this.tags,
    required this.onDelete,
    required this.onUpdate,
  });

  final List<TagSearchItem> tags;
  final void Function(TagSearchItem tag) onDelete;
  final void Function(TagSearchItem oldTag, String newTag)? onUpdate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tagItem = tags[index];
          final chip = SelectedTagChip(
            tagSearchItem: tagItem,
            onDeleted: () => onDelete(tagItem),
            onUpdated: (tag) => onUpdate?.call(tagItem, tag),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: tagItem.isRaw
                ? SelectedTagContextMenu(
                    tag: tagItem.toString(),
                    child: chip,
                  )
                : GeneralTagContextMenu(
                    tag: tagItem.rawTag,
                    child: chip,
                  ),
          );
        },
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
