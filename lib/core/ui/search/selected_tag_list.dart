// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/ui/search/selected_tag_chip.dart';
import 'package:boorusama/i18n.dart';

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
      firstChild: Row(children: [
        const SizedBox(width: 10),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showMaterialModalBottomSheet(
            context: context,
            builder: (context) => ModalSelectedTag(
              onClear: () => onClear.call(),
              onBulkDownload: () => onBulkDownload(tags),
            ),
          ),
          child: const Icon(Icons.more_vert),
        ),
        Expanded(
          child: _SelectedTagChips(
            tags: tags,
            onDelete: onDelete,
          ),
        ),
      ]),
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
    return Container(
      margin: const EdgeInsets.only(left: 8),
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

// ignore: prefer-single-widget-per-file
class ModalSelectedTag extends StatelessWidget {
  const ModalSelectedTag({
    super.key,
    this.onClear,
    this.onBulkDownload,
  });

  final void Function()? onClear;
  final void Function()? onBulkDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('search.remove_all_selected').tr(),
              leading: const Icon(Icons.clear_all),
              onTap: () {
                Navigator.of(context).pop();
                onClear?.call();
              },
            ),
            ListTile(
              title: const Text('download.bulk_download').tr(),
              leading: const Icon(Icons.download),
              onTap: () {
                Navigator.of(context).pop();
                onBulkDownload?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
