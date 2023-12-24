// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/selected_tag_chip.dart';
import 'package:boorusama/foundation/i18n.dart';

class SelectedTagList extends StatelessWidget {
  const SelectedTagList({
    super.key,
    required this.tags,
    required this.onClear,
    required this.onDelete,
    required this.onBulkDownload,
  });

  final List<TagSearchItem> tags;
  final VoidCallback onClear;
  final void Function(TagSearchItem tag) onDelete;
  final void Function(List<TagSearchItem> tags) onBulkDownload;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Row(
        children: [
          PopupMenuButton(
            icon: const Icon(
              Symbols.more_vert,
              weight: 400,
            ),
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 0) {
                onClear.call();
              } else if (value == 1) {
                onBulkDownload(tags);
              }
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: const Text('search.remove_all_selected').tr(),
              ),
              PopupMenuItem(
                value: 1,
                child: const Text('download.bulk_download').tr(),
              ),
            ],
          ),
          Expanded(
            child: _SelectedTagChips(
              tags: tags,
              onDelete: onDelete,
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
  });

  final List<TagSearchItem> tags;
  final void Function(TagSearchItem tag) onDelete;

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
            child: SelectedTagChip(
              tagSearchItem: tags[index],
              onDeleted: () => onDelete(tags[index]),
            ),
          );
        },
      ),
    );
  }
}
