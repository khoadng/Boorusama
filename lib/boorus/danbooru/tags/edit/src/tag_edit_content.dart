// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../danbooru.dart';
import 'providers/tag_edit_notifier.dart';
import 'tag_edit_state.dart';
import 'tag_edit_view_controller.dart';
import 'views/tag_edit_ai_view.dart';
import 'views/tag_edit_favorite_view.dart';
import 'views/tag_edit_wiki_view.dart';
import 'widgets/raw_tag_edit_select_button.dart';
import 'widgets/tag_edit_container.dart';
import 'widgets/tag_edit_tag_list_section.dart';

class TagEditContent extends ConsumerWidget {
  const TagEditContent({
    required this.ratingSelector,
    required this.scrollController,
    super.key,
    this.source,
  });

  final ScrollController scrollController;
  final Widget ratingSelector;
  final Widget? source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: ratingSelector,
        ),
        const SliverSizedBox(height: 8),
        if (source != null)
          SliverToBoxAdapter(
            child: source,
          ),
        const SliverSizedBox(height: 8),
        const SliverTagEditTagListSection(),
      ],
    );
  }
}

class TagEditExpandContent extends ConsumerWidget {
  const TagEditExpandContent({
    required this.viewController,
    required this.maxHeight,
    super.key,
  });

  final TagEditViewController viewController;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final booru = ref.watch(danbooruProvider);
    final aiTagSupport = booru.hasAiTagSupported(config.url);

    final notifier = ref.watch(tagEditProvider.notifier);
    final expandMode =
        ref.watch(tagEditProvider.select((value) => value.expandMode));

    return switch (expandMode) {
      TagEditExpandMode.favorite => TagEditContainer(
          title: 'Favorites',
          maxHeight: maxHeight,
          viewController: viewController,
          child: const TagEditFavoriteViewWithStates(),
        ),
      TagEditExpandMode.related => TagEditContainer(
          title: 'Related',
          maxHeight: maxHeight,
          viewController: viewController,
          child: const TagEditWikiViewWithStates(),
        ),
      TagEditExpandMode.aiTag => TagEditContainer(
          title: 'Suggested',
          maxHeight: maxHeight,
          viewController: viewController,
          child: const TagEditAITagViewWithStates(),
        ),
      null => Container(
          margin: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              RawTagEditSelectButton(
                title: 'Search',
                onPressed: () {
                  goToQuickSearchPage(
                    context,
                    ref: ref,
                    onSelected: (tag, isRaw) {
                      if (isRaw) {
                        final tags = tag.split(' ');

                        notifier.addTags(tags);
                      } else {
                        notifier.addTag(tag);
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 4),
              const TagEditModeSelectButton(
                title: 'Favorites',
                mode: TagEditExpandMode.favorite,
              ),
              const SizedBox(width: 4),
              const TagEditModeSelectButton(
                title: 'Related',
                mode: TagEditExpandMode.related,
              ),
              if (aiTagSupport) ...[
                const SizedBox(width: 4),
                const TagEditModeSelectButton(
                  title: 'Suggested',
                  mode: TagEditExpandMode.aiTag,
                ),
              ],
            ],
          ),
        ),
    };
  }
}

class TagEditModeSelectButton extends ConsumerWidget {
  const TagEditModeSelectButton({
    required this.title,
    required this.mode,
    super.key,
  });

  final String title;
  final TagEditExpandMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);

    return RawTagEditSelectButton(
      title: title,
      onPressed: () {
        notifier.setExpandMode(mode);
      },
    );
  }
}

class TagEditWikiViewWithStates extends ConsumerWidget {
  const TagEditWikiViewWithStates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final tags = ref.watch(tagEditProvider.select((value) => value.tags));
    final selectedTag =
        ref.watch(tagEditProvider.select((value) => value.selectedTag));

    return TagEditWikiView(
      tag: selectedTag,
      onRemoved: (tag) {
        notifier.removeTag(tag);
      },
      onAdded: (tag) {
        notifier.addTag(tag);
      },
      isSelected: (tag) => tags.contains(tag),
    );
  }
}

class TagEditAITagViewWithStates extends ConsumerWidget {
  const TagEditAITagViewWithStates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final tags = ref.watch(tagEditProvider.select((value) => value.tags));

    return TagEditAITagView(
      postId: notifier.postId,
      onRemoved: (tag) {
        notifier.removeTag(tag);
      },
      onAdded: (tag) {
        notifier.addTag(tag);
      },
      isSelected: (tag) => tags.contains(tag),
    );
  }
}

class TagEditFavoriteViewWithStates extends ConsumerWidget {
  const TagEditFavoriteViewWithStates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final tags = ref.watch(tagEditProvider.select((value) => value.tags));

    return TagEditFavoriteView(
      onRemoved: (tag) {
        notifier.removeTag(tag);
      },
      onAdded: (tag) {
        notifier.addTag(tag);
      },
      isSelected: (tag) => tags.contains(tag),
    );
  }
}
