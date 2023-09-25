// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'widgets/saved_searches/saved_search_landing_view.dart';

class SavedSearchFeedPage extends ConsumerWidget {
  const SavedSearchFeedPage({
    super.key,
  });

  static Widget of(BuildContext context) {
    return const CustomContextMenuOverlay(
      child: SavedSearchFeedPage(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruSavedSearchStateProvider);
    final selectedSearch = ref.watch(danbooruSavedSearchSelectedProvider);

    return state.when(
      data: (state) => switch (state) {
        SavedSearchState.landing => const SavedSearchLandingView(),
        SavedSearchState.feed => DanbooruPostScope(
            fetcher: (page) => ref
                .read(danbooruPostRepoProvider)
                .getPosts(selectedSearch.toQuery(), page),
            builder: (context, controller, errors) => _PostList(
              controller: controller,
              errors: errors,
            ),
          ),
      },
      error: (error, stackTrace) => const ErrorBox(),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _PostList extends ConsumerWidget {
  const _PostList({
    required this.controller,
    required this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      danbooruSavedSearchSelectedProvider,
      (previous, next) async {
        if (previous != next) {
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return DanbooruInfinitePostList(
      errors: errors,
      controller: controller,
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: const Text('saved_search.saved_search_feed').tr(),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          actions: [
            IconButton(
              onPressed: () => goToSavedSearchEditPage(context),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            height: 50,
            child: const _SavedSearchList(),
          ),
        ),
      ],
    );
  }
}

class _SavedSearchList extends ConsumerWidget {
  const _SavedSearchList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(danbooruSavedSearchAvailableProvider);
    final selectedSearch = ref.watch(danbooruSavedSearchSelectedProvider);

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: searches.length,
      itemBuilder: (context, index) {
        final isSelected = selectedSearch == searches[index];

        final text = searches[index].labels.firstOption;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            disabledColor: context.theme.chipTheme.disabledColor,
            backgroundColor: context.theme.chipTheme.backgroundColor,
            selectedColor: context.theme.chipTheme.selectedColor,
            selected: isSelected,
            onSelected: (selected) {
              if (!isSelected) {
                ref.read(danbooruSavedSearchSelectedProvider.notifier).state =
                    searches[index];
              }
            },
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: text.fold(
                () => 12,
                (t) => t.length < 4 ? 12 : 4,
              ),
            ),
            labelPadding: const EdgeInsets.all(1),
            visualDensity: VisualDensity.compact,
            side: BorderSide(
              width: 0.5,
              color: context.theme.hintColor,
            ),
            label: Text(
              text.fold(
                () => '<empty>',
                (t) => t.replaceUnderscoreWithSpace(),
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        );
      },
    );
  }
}
