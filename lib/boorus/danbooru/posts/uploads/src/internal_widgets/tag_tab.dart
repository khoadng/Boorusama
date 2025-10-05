// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/tags/categories/tag_category.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/utils/flutter_utils.dart';
import '../../../../sources/providers.dart';
import '../../../../tags/edit/widgets.dart';
import '../pages/tag_edit_upload_text_controller.dart';
import '../types/danbooru_upload_post.dart';
import 'rating_selector.dart';
import 'text_field.dart';

class TagEditUploadTag extends ConsumerWidget {
  const TagEditUploadTag({
    super.key,
    required this.textEditingController,
    required this.post,
  });

  final TagEditUploadTextController textEditingController;
  final DanbooruUploadPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        listTileTheme: Theme.of(context).listTileTheme.copyWith(
          visualDensity: const ShrinkVisualDensity(),
        ),
        dividerColor: Colors.transparent,
      ),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: TagEditUploadRatingSelector(),
          ),
          const SliverSizedBox(height: 8),
          SliverToBoxAdapter(
            child: TagEditUploadTextField(
              textEditingController: textEditingController,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildTranslated(ref),
          ),
          SliverToBoxAdapter(
            child: _RelatedExpansionTile(
              textEditingController: textEditingController,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFavorites(),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslated(WidgetRef ref) {
    return ref
        .watch(danbooruSourceProvider(post.pageUrl))
        .when(
          data: (source) {
            final translatedTags = [
              if (source.artist?.artists != null)
                ...source.artist!.artists!.map(
                  (e) => (
                    name: e.name ?? '',
                    count: null,
                    category: TagCategory.artist(),
                  ),
                ),
            ];

            return translatedTags.isNotEmpty
                ? ValueListenableBuilder(
                    valueListenable: textEditingController,
                    builder: (context, value, child) {
                      final tags = value.text.split(' ');

                      return ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Translated'.hc),
                        controlAffinity: ListTileControlAffinity.leading,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Wrap(
                                  spacing: 4,
                                  children: [
                                    for (final tag in translatedTags)
                                      BooruChip(
                                        visualDensity:
                                            const ShrinkVisualDensity(),
                                        onPressed: () {
                                          final name = tag.name;

                                          if (tags.contains(name)) {
                                            textEditingController.removeTag(
                                              name,
                                            );
                                          } else {
                                            textEditingController.addTag(name);
                                          }
                                        },
                                        showBackground: tags.contains(tag.name),
                                        showBorder: tags.contains(tag.name),
                                        label: Text(
                                          tag.name.replaceAll('_', ' '),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                        color: ref.watch(
                                          tagColorProvider(
                                            (
                                              ref.watchConfigAuth,
                                              tag.category.name,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }

  Widget _buildFavorites() {
    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, value, child) {
        final tags = value.text.split(' ');

        return ExpansionTile(
          title: Text('Favorites'.hc),
          controlAffinity: ListTileControlAffinity.leading,
          children: [
            TagEditFavoriteView(
              onRemoved: (tag) {
                textEditingController.removeTag(tag);
              },
              onAdded: (tag) {
                textEditingController.addTag(tag);
              },
              isSelected: (tag) => tags.contains(tag),
            ),
          ],
        );
      },
    );
  }
}

class _RelatedExpansionTile extends ConsumerStatefulWidget {
  const _RelatedExpansionTile({
    required this.textEditingController,
  });

  final TagEditUploadTextController textEditingController;

  @override
  ConsumerState<_RelatedExpansionTile> createState() =>
      _RelatedExpansionTileState();
}

class _RelatedExpansionTileState extends ConsumerState<_RelatedExpansionTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.textEditingController,
      builder: (context, value, child) {
        final tags = value.text.split(' ');

        return ValueListenableBuilder<String?>(
          valueListenable: widget.textEditingController.selectedTagNotifier,
          builder: (context, selectedTagValue, child) {
            final selectedTag = selectedTagValue?.replaceAll('_', ' ') ?? '';

            return ExpansionTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Row(
                children: [
                  Text('Related'.hc),
                  const SizedBox(width: 8),
                  if (selectedTag.isNotEmpty)
                    BooruChip(
                      visualDensity: const ShrinkVisualDensity(),
                      onPressed: () {},
                      label: Text(
                        selectedTag,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: ref.watch(
                        tagColorProvider((ref.watchConfigAuth, 'general')),
                      ),
                    ),
                ],
              ),
              onExpansionChanged: (value) {
                setState(() {
                  _expanded = value;
                });
              },
              children: [
                if (_expanded)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TagEditWikiView(
                      tag: selectedTagValue,
                      onRemoved: (tag) {
                        widget.textEditingController.removeTag(tag);
                      },
                      onAdded: (tag) {
                        widget.textEditingController.addTag(tag);
                      },
                      isSelected: (tag) => tags.contains(tag),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
