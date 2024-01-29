// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import '../common/option_tags_arena.dart';
import 'add_tag_button.dart';
import 'import_tag_button.dart';

const kSearchSelectedFavoriteTagLabelKey = 'search_selected_favorite_tag';

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
    final selectedLabel =
        ref.watch(miscDataProvider(kSearchSelectedFavoriteTagLabelKey));

    return FavoriteTagsFilterScope(
      initialValue: selectedLabel,
      builder: (_, tags, labels, selected) => OptionTagsArena(
        editable: tags.isNotEmpty,
        title: 'favorite_tags.favorites'.tr(),
        titleTrailing: (editMode) => TagLabelsDropDownButton(
          backgroundColor: Colors.transparent,
          tagLabels: labels,
          selectedLabel: selected,
          onChanged: (value) => ref
              .read(
                  miscDataProvider(kSearchSelectedFavoriteTagLabelKey).notifier)
              .put(value),
        ),
        childrenBuilder: (editMode) =>
            _buildFavoriteTags(context, ref, tags, editMode),
      ),
    );
  }

  List<Widget> _buildFavoriteTags(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteTag> tags,
    bool editMode,
  ) {
    return [
      ...tags.mapIndexed((index, tag) {
        final colors = context.generateChipColors(
          context.themeMode.isDark ? Colors.white : Colors.black,
          ref.watch(settingsProvider),
        );

        return RawChip(
          visualDensity: VisualDensity.compact,
          onPressed: editMode ? null : () => onTagTap?.call(tag.name),
          label: Text(
            tag.name.replaceUnderscoreWithSpace(),
            style: TextStyle(
              color: colors?.foregroundColor,
            ),
          ),
          backgroundColor: colors?.backgroundColor,
          side: colors != null
              ? BorderSide(
                  color: colors.borderColor,
                  width: 1,
                )
              : null,
          deleteIcon: Icon(
            Symbols.close,
            size: 18,
            color: colors?.foregroundColor,
          ),
          onDeleted: editMode
              ? () => ref.read(favoriteTagsProvider.notifier).remove(tag.name)
              : null,
        );
      }),
      if (tags.isEmpty) ...[
        Container(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: AddTagButton(onPressed: onAddTagRequest),
        ),
        Container(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: Text(
            'favorite_tags.or'.tr(),
            style: context.textTheme.titleLarge,
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
