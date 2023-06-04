// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/i18n.dart';
import '../common/option_tags_arena.dart';
import 'add_tag_button.dart';
import 'import_tag_button.dart';

class FavoriteTagsSection extends ConsumerWidget {
  const FavoriteTagsSection({
    super.key,
    required this.onTagTap,
    required this.onAddTagRequest,
  });

  final ValueChanged<String>? onTagTap;
  final VoidCallback onAddTagRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(favoriteTagsProvider);

    return OptionTagsArena(
      editable: tags.isNotEmpty,
      title: 'favorite_tags.favorites'.tr(),
      childrenBuilder: (editMode) =>
          _buildFavoriteTags(context, ref, tags, editMode),
      titleTrailing: (editMode) => editMode && tags.isNotEmpty
          ? PopupMenuButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              onSelected: (value) {
                if (value == 'import') {
                  goToFavoriteTagImportPage(context);
                } else if (value == 'export') {
                  ref.read(favoriteTagsProvider.notifier).export(
                    onDone: (tagString) {
                      Clipboard.setData(
                        ClipboardData(text: tagString),
                      ).then((value) => showSimpleSnackBar(
                            context: context,
                            content: const Text(
                              'favorite_tags.export_notification',
                            ).tr(),
                          ));
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'import',
                  child: const Text('favorite_tags.import').tr(),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: const Text('favorite_tags.export').tr(),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  List<Widget> _buildFavoriteTags(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteTag> tags,
    bool editMode,
  ) {
    return [
      ...tags.mapIndexed((index, tag) => RawChip(
            onPressed: editMode ? null : () => onTagTap?.call(tag.name),
            label: Text(tag.name.replaceAll('_', ' ')),
            deleteIcon: const Icon(
              Icons.close,
              size: 18,
            ),
            onDeleted: editMode
                ? () => ref.read(favoriteTagsProvider.notifier).remove(index)
                : null,
          )),
      if (tags.isEmpty) ...[
        AddTagButton(onPressed: onAddTagRequest),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 8),
          child: Text(
            'favorite_tags.or'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const ImportTagButton(),
      ],
      if (editMode && tags.isNotEmpty)
        AddTagButton(
          onPressed: onAddTagRequest,
        ),
    ];
  }
}
