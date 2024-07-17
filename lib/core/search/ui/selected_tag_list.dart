// Flutter imports:
import 'package:flutter/material.dart';

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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GeneralTagContextMenu(
              tag: tags[index].rawTag,
              child: SelectedTagChip(
                tagSearchItem: tags[index],
                onDeleted: () => onDelete(tags[index]),
                onUpdated: (tag) => onUpdate?.call(tags[index], tag),
              ),
            ),
          );
        },
      ),
    );
  }
}
