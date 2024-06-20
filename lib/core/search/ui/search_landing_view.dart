// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/search/search.dart';
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
    this.backgroundColor,
    this.scrollController,
  });

  final ValueChanged<String>? onHistoryTap;
  final ValueChanged<String>? onTagTap;
  final ValueChanged<SearchHistory> onHistoryRemoved;
  final VoidCallback onHistoryCleared;
  final Widget Function(BuildContext context)? metatagsBuilder;
  final Widget Function(BuildContext context)? trendingBuilder;
  final Widget Function(BuildContext context)? noticeBuilder;
  final Color? backgroundColor;
  final ScrollController? scrollController;

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
    final selectedLabel =
        ref.watch(miscDataProvider(kSearchSelectedFavoriteTagLabelKey));

    return Container(
      color: widget.backgroundColor,
      child: FadeTransition(
        opacity: animationController,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.noticeBuilder != null) ...[
                widget.noticeBuilder!.call(context),
              ],
              if (widget.metatagsBuilder != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.metatagsBuilder!(context),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(thickness: 1),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FavoriteTagsSection(
                  selectedLabel: selectedLabel,
                  onTagTap: (value) {
                    _onTagTap(value, ref);
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (widget.trendingBuilder != null) ...[
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.trendingBuilder!.call(context),
                ),
                const SizedBox(height: 8),
              ],
              ref.watch(searchHistoryProvider).maybeWhen(
                    data: (histories) => Column(
                      children: [
                        const Divider(thickness: 1),
                        SearchHistorySection(
                          histories: histories.histories,
                          onHistoryTap: (history) {
                            _onHistoryTap(history, ref);
                          },
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
                    orElse: () => const SizedBox.shrink(),
                  ),
              SizedBox(
                height: MediaQuery.viewPaddingOf(context).bottom + 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTagTap(String value, WidgetRef ref) {
    widget.onTagTap?.call(value);
  }

  void _onHistoryTap(String value, WidgetRef ref) {
    widget.onHistoryTap?.call(value);
  }

  void _onHistoryCleared() => widget.onHistoryCleared();

  void _onHistoryRemoved(SearchHistory value) => widget.onHistoryRemoved(value);
}
