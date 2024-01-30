// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/utils/color_utils.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'edit_favorite_tag_sheet.dart';
import 'favorite_tag_label_details_page.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

final selectedFavoriteTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

class FavoriteTagsPage extends ConsumerWidget {
  const FavoriteTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite tags'),
      ),
      body: FavoriteTagsFilterScope(
        filterQuery: ref.watch(selectedFavoriteTagQueryProvider),
        builder: (context, tags, labels, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BooruSearchBar(
                hintText: 'Filter...',
                onChanged: (value) => ref
                    .read(selectedFavoriteTagQueryProvider.notifier)
                    .state = value,
              ),
            ),
            tags.isNotEmpty
                ? Expanded(
                    child: _buildTags(tags, ref),
                  )
                : const Center(
                    child: Text('No tags'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(
    List<FavoriteTag> tags,
    WidgetRef ref,
  ) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final labels = tag.labels ?? <String>[];
        final colors = context.generateChipColors(
          context.colorScheme.primary,
          ref.watch(settingsProvider),
        );

        return ListTile(
          title: Text(tag.name),
          subtitle: labels.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in labels)
                        _buildChip(colors, context, label),
                    ],
                  ),
                )
              : null,
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  final tag = tags[index];
                  ref.read(favoriteTagsProvider.notifier).remove(tag.name);
                  break;
                case 'edit':
                  showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) => EditFavoriteTagSheet(
                      initialValue: tag,
                      title: tag.name,
                      onSubmit: (tag) {
                        ref.read(favoriteTagsProvider.notifier).update(
                              tag.name,
                              tag,
                            );
                      },
                    ),
                  );
                  break;
              }
            },
            itemBuilder: const {
              'edit': Text('Edit'),
              'delete': Text('Delete'),
            },
          ),
        );
      },
    );
  }

  Widget _buildChip(ChipColors? colors, BuildContext context, String label) {
    return SizedBox(
      height: 28,
      child: RawChip(
        onPressed: () {
          context.navigator.push(
            CupertinoPageRoute(
              builder: (context) => FavoriteTagLabelDetailsPage(
                label: label,
              ),
            ),
          );
        },
        padding: isMobilePlatform() ? const EdgeInsets.all(4) : EdgeInsets.zero,
        visualDensity: const ShrinkVisualDensity(),
        backgroundColor: colors?.backgroundColor,
        side: colors != null
            ? BorderSide(
                color: colors.borderColor,
                width: 1,
              )
            : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.screenWidth * 0.7,
          ),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: colors?.foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
