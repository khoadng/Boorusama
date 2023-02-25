// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';
import '../common/option_tags_arena.dart';
import 'add_tag_button.dart';
import 'import_tag_button.dart';

class FavoriteTagsSection extends StatelessWidget {
  const FavoriteTagsSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((FavoriteTagBloc bloc) => bloc.state.tags);

    return OptionTagsArena(
      editable: tags.isNotEmpty,
      title: 'favorite_tags.favorites'.tr(),
      childrenBuilder: (editMode) =>
          _buildFavoriteTags(context, tags, editMode),
      titleTrailing: (editMode) => editMode && tags.isNotEmpty
          ? PopupMenuButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              onSelected: (value) {
                final bloc = context.read<FavoriteTagBloc>();
                if (value == 'import') {
                  goToFavoriteTagImportPage(context, bloc);
                } else if (value == 'export') {
                  bloc.add(
                    FavoriteTagExported(
                      onDone: (tagString) => Clipboard.setData(
                        ClipboardData(text: tagString),
                      ).then((value) => showSimpleSnackBar(
                            context: context,
                            content: const Text(
                              'favorite_tags.export_notification',
                            ).tr(),
                          )),
                    ),
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
                ? () => context
                    .read<FavoriteTagBloc>()
                    .add(FavoriteTagRemoved(index: index))
                : null,
          )),
      if (tags.isEmpty) ...[
        const AddTagButton(),
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 8),
          child: Text(
            'favorite_tags.or'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const ImportTagButton(),
      ],
      if (editMode && tags.isNotEmpty) const AddTagButton(),
    ];
  }
}
