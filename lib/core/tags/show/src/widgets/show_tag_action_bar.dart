// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../configs/config/types.dart';
import '../../../../search/search/routes.dart';
import '../../../../search/selected_tags/tag.dart';
import '../../../../widgets/animated_footer.dart';
import '../../../../widgets/widgets.dart';
import '../../../tag/providers.dart';
import '../../../tag/tag.dart';

class ShowTagActionBar extends ConsumerWidget {
  const ShowTagActionBar({
    required this.auth,
    required this.originalItems,
    required this.onAddToBlacklist,
    required this.onAddToGlobalBlacklist,
    required this.onAddToFavoriteTags,
    super.key,
  });

  final BooruConfigAuth auth;
  final List<Tag> originalItems;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onAddToGlobalBlacklist;
  final void Function(Tag tag)? onAddToFavoriteTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectionConsumer(
      builder: (context, controller, _) {
        final tags = controller.selectedFrom(originalItems).toList();

        return SelectionModeAnimatedFooter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tags.isNotEmpty)
                _TagPreviewContainer(
                  auth: auth,
                  tags: tags,
                ),
              MultiSelectionActionBar(
                height: 68,
                children: [
                  MultiSelectButton(
                    onPressed: tags.isNotEmpty
                        ? () {
                            goToSearchPage(
                              ref,
                              tags: SearchTagSet.fromList(
                                tags.map((e) => e.rawName).toList(),
                              ),
                            );
                            controller.disable();
                          }
                        : null,
                    icon: const Icon(Symbols.search),
                    name: context.t.tags.actions.search,
                  ),
                  MultiSelectButton(
                    onPressed: tags.isNotEmpty
                        ? () => _copySelectedTags(
                            tags,
                            context,
                            controller,
                          )
                        : null,
                    icon: const Icon(Symbols.content_copy),
                    name: context.t.tags.actions.copy,
                  ),
                  if (onAddToBlacklist != null)
                    MultiSelectButton(
                      onPressed: tags.isNotEmpty
                          ? () => _addSelectedToBlacklist(
                              tags,
                              controller,
                            )
                          : null,
                      icon: const Icon(Symbols.block),
                      name: context.t.tags.actions.blacklist,
                    ),
                  MultiSelectButton(
                    onPressed: tags.isNotEmpty
                        ? () => _addSelectedToGlobalBlacklist(
                            tags,
                            controller,
                          )
                        : null,
                    icon: const Icon(Symbols.block),
                    name: context.t.tags.actions.blacklist_global,
                  ),
                  MultiSelectButton(
                    onPressed: tags.isNotEmpty
                        ? () => _addSelectedToFavorites(tags, controller)
                        : null,
                    icon: const Icon(Symbols.favorite),
                    name: context.t.post.action.favorite,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _copySelectedTags(
    List<Tag> tags,
    BuildContext context,
    SelectionModeController controller,
  ) {
    final selectedTags = tags.map((e) => e.rawName).join(' ');

    AppClipboard.copyWithDefaultToast(
      context,
      selectedTags,
    );

    controller.disable();
  }

  void _addSelectedToBlacklist(
    List<Tag> tags,
    SelectionModeController controller,
  ) {
    for (final tag in tags) {
      if (onAddToBlacklist case final callback?) {
        callback(tag);
      }
    }

    controller.disable();
  }

  void _addSelectedToGlobalBlacklist(
    List<Tag> tags,
    SelectionModeController controller,
  ) {
    for (final tag in tags) {
      if (onAddToGlobalBlacklist case final callback?) {
        callback(tag);
      }
    }

    controller.disable();
  }

  void _addSelectedToFavorites(
    List<Tag> tags,
    SelectionModeController controller,
  ) {
    for (final tag in tags) {
      if (onAddToFavoriteTags case final callback?) {
        callback(tag);
      }
    }
    controller.disable();
  }
}

class _TagPreviewContainer extends ConsumerWidget {
  const _TagPreviewContainer({
    required this.tags,
    required this.auth,
  });

  final List<Tag> tags;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            ...tags.map(
              (tag) => TextSpan(
                text: '${tag.displayName}  ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ref.watch(
                    tagColorProvider(
                      (auth, tag.category.name),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
