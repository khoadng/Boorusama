// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../cache/providers.dart';
import '../../../../tags/favorites/favorited.dart';
import '../../../histories/all.dart';
import '../../../selected_tags/tag_search_item.dart';
import '../pages/selected_tag_edit_dialog.dart';
import '../widgets/constants.dart';
import '../widgets/favorite_tags_section.dart';

class SearchLandingView extends ConsumerStatefulWidget {
  const SearchLandingView({
    super.key,
    this.onHistoryTap,
    this.onFavTagTap,
    this.onRawTagTap,
    this.metatags,
    this.trending,
    this.notice,
    this.backgroundColor,
    this.scrollController,
    this.disableAnimation = false,
    this.reverseScheme = false,
    this.reverse,
  });

  final ValueChanged<SearchHistory>? onHistoryTap;
  final ValueChanged<FavoriteTag>? onFavTagTap;
  final ValueChanged<String>? onRawTagTap;
  final Widget? metatags;
  final Widget? trending;
  final Widget? notice;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool disableAnimation;
  final bool reverseScheme;
  final bool? reverse;

  @override
  ConsumerState<SearchLandingView> createState() => _SearchLandingViewState();
}

class _SearchLandingViewState extends ConsumerState<SearchLandingView>
    with TickerProviderStateMixin {
  late final animationController = !widget.disableAnimation
      ? AnimationController(
          vsync: this,
          duration: kThemeAnimationDuration,
        )
      : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          animationController?.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel =
        ref.watch(miscDataProvider(kSearchSelectedFavoriteTagLabelKey));

    final children = [
      const SizedBox(height: 8),
      if (widget.notice != null) widget.notice!,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: QueryActionsSection(
          childrenBuilder: () => [],
          onTagAdded: (value) {
            widget.onRawTagTap?.call(value);
          },
        ),
      ),
      const Divider(thickness: 1),
      if (widget.metatags != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: widget.metatags,
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
      if (widget.trending != null) ...[
        const Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: widget.trending,
        ),
        const SizedBox(height: 8),
      ],
      ref.watch(searchHistoryProvider).maybeWhen(
            data: (histories) => Column(
              children: [
                const Divider(thickness: 1),
                SearchHistorySection(
                  reverseScheme: widget.reverseScheme,
                  histories: histories.histories,
                  onHistoryTap: (history) {
                    _onHistoryTap(history, ref);
                  },
                  onFullHistoryRequested: () {
                    goToSearchHistoryPage(
                      context,
                      onTap: (value) {
                        Navigator.of(context).pop();
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
    ];

    final view = SingleChildScrollView(
      reverse: widget.reverse ?? false,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            (widget.reverse ?? false) ? children.reversed.toList() : children,
      ),
    );

    return Container(
      color: widget.backgroundColor,
      child: animationController != null
          ? FadeTransition(
              opacity: animationController!,
              child: view,
            )
          : view,
    );
  }

  void _onTagTap(FavoriteTag value, WidgetRef ref) {
    widget.onFavTagTap?.call(value);
  }

  void _onHistoryTap(SearchHistory value, WidgetRef ref) {
    widget.onHistoryTap?.call(value);
  }
}

class QueryActionsSection extends StatelessWidget {
  const QueryActionsSection({
    required this.childrenBuilder,
    required this.onTagAdded,
    super.key,
    this.titleTrailing,
  });

  final Widget Function()? titleTrailing;
  final List<Widget> Function() childrenBuilder;
  final void Function(String) onTagAdded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Text(
                  //   'Actions'.toUpperCase(),
                  //   style: Theme.of(context).titleSmall?.copyWith(
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    onPressed: () {
                      showDialog(
                        routeSettings: const RouteSettings(
                          name: 'raw_query_input',
                        ),
                        context: context,
                        builder: (c) {
                          return SelectedTagEditDialog(
                            tag: const TagSearchItem.raw(tag: ''),
                            onUpdated: (tag) {
                              if (tag.isNotEmpty) {
                                onTagAdded(tag);
                              }
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Symbols.add,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fill: 1,
                        ),
                        Text(
                          'Raw query',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              titleTrailing?.call() ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
