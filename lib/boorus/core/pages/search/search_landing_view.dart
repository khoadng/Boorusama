// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/search/search.dart';
import 'package:boorusama/boorus/core/feat/tags/tags.dart';
import 'package:boorusama/boorus/core/pages/search/favorite_tags/favorite_tags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_history_section.dart';
import 'package:boorusama/boorus/core/router.dart';

class SearchLandingView extends ConsumerStatefulWidget {
  const SearchLandingView({
    super.key,
    this.onHistoryTap,
    this.metatagsBuilder,
    this.trendingBuilder,
  });

  final ValueChanged<String>? onHistoryTap;
  final Widget Function(BuildContext context)? metatagsBuilder;
  final Widget Function(BuildContext context)? trendingBuilder;

  @override
  ConsumerState<SearchLandingView> createState() => _SearchLandingViewState();
}

class _SearchLandingViewState extends ConsumerState<SearchLandingView>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final histories = ref.watch(searchHistoryProvider);

    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.metatagsBuilder != null) ...[
                widget.metatagsBuilder!(context),
                const SizedBox(
                  height: 10,
                ),
                const Divider(thickness: 1),
              ],
              FavoriteTagsSection(
                onAddTagRequest: () {
                  goToQuickSearchPage(
                    context,
                    ref: ref,
                    onSubmitted: (context, text) {
                      Navigator.of(context).pop();
                      ref.read(favoriteTagsProvider.notifier).add(text);
                    },
                    onSelected: (tag) =>
                        ref.read(favoriteTagsProvider.notifier).add(tag.value),
                  );
                },
                onTagTap: (value) {
                  _onTagTap(value, ref);
                },
              ),
              if (widget.trendingBuilder != null) ...[
                widget.trendingBuilder!.call(context),
              ],
              SearchHistorySection(
                histories: histories.histories,
                onHistoryTap: (history) {
                  _onHistoryTap(history, ref);
                  widget.onHistoryTap?.call(history);
                },
                onHistoryRemoved: (value) => _onHistoryRemoved(ref, value),
                onHistoryCleared: () => _onHistoryCleared(ref),
                onFullHistoryRequested: () {
                  goToSearchHistoryPage(
                    context,
                    onClear: () => _onHistoryCleared(ref),
                    onRemove: (value) => _onHistoryRemoved(ref, value),
                    onTap: (value) {
                      Navigator.of(context).pop();
                      _onHistoryTap(value, ref);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTagTap(String value, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(searchProvider.notifier).tapTag(value);
  }

  void _onHistoryTap(String value, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(searchProvider.notifier).tapHistoryTag(value);
  }

  void _onHistoryCleared(WidgetRef ref) =>
      ref.read(searchProvider.notifier).clearHistories();

  void _onHistoryRemoved(WidgetRef ref, SearchHistory value) =>
      ref.read(searchProvider.notifier).removeHistory(value);
}
