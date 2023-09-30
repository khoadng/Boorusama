// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/search/favorite_tags/favorite_tags_section.dart';
import 'package:boorusama/core/pages/search/search_history_section.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/flutter.dart';

class SearchLandingView extends ConsumerStatefulWidget {
  const SearchLandingView({
    super.key,
    this.onHistoryTap,
    this.onTagTap,
    this.metatagsBuilder,
    this.trendingBuilder,
    required this.onHistoryRemoved,
    required this.onHistoryCleared,
    this.noticeBuilder,
  });

  final ValueChanged<String>? onHistoryTap;
  final ValueChanged<String>? onTagTap;
  final ValueChanged<SearchHistory> onHistoryRemoved;
  final VoidCallback onHistoryCleared;
  final Widget Function(BuildContext context)? metatagsBuilder;
  final Widget Function(BuildContext context)? trendingBuilder;
  final Widget Function(BuildContext context)? noticeBuilder;

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
    final favoritesNotifier = ref.watch(favoriteTagsProvider.notifier);

    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.noticeBuilder != null) ...[
                widget.noticeBuilder!.call(context),
              ],
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
                      context.navigator.pop();
                      favoritesNotifier.add(text);
                    },
                    onSelected: (tag) => favoritesNotifier.add(tag.value),
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
                onHistoryRemoved: (value) => _onHistoryRemoved(value),
                onHistoryCleared: () => _onHistoryCleared(),
                onFullHistoryRequested: () {
                  goToSearchHistoryPage(
                    context,
                    onClear: () => _onHistoryCleared(),
                    onRemove: (value) => _onHistoryRemoved(value),
                    onTap: (value) {
                      context.navigator.pop();
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
    widget.onTagTap?.call(value);
  }

  void _onHistoryTap(String value, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onHistoryTap?.call(value);
  }

  void _onHistoryCleared() => widget.onHistoryCleared();

  void _onHistoryRemoved(SearchHistory value) => widget.onHistoryRemoved(value);
}
