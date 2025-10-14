// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../cache/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../tags/favorites/types.dart';
import '../../../histories/providers.dart';
import '../../../histories/routes.dart';
import '../../../histories/types.dart';
import '../../../histories/widgets.dart';
import '../../../selected_tags/tag_search_item.dart';
import '../pages/selected_tag_edit_dialog.dart';
import '../types/search_bar_position.dart';
import '../widgets/constants.dart';
import '../widgets/favorite_tags_section.dart';

class SearchLandingView extends ConsumerStatefulWidget {
  const SearchLandingView({
    super.key,
    this.backgroundColor,
    this.scrollController,
    this.disableAnimation = false,
    this.reverse,
    required this.child,
  });

  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool disableAnimation;
  final Widget child;
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
    final searchBarPosition = ref.watch(searchBarPositionProvider);
    final reverse = searchBarPosition == SearchBarPosition.bottom;

    final view = SingleChildScrollView(
      reverse: widget.reverse ?? reverse,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: widget.scrollController,
      child: widget.child,
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
}

class DefaultSearchLandingChildren extends ConsumerWidget {
  const DefaultSearchLandingChildren({
    super.key,
    this.notice,
    required this.children,
    this.reverse,
  });

  final bool? reverse;

  final Widget? notice;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBarPosition = ref.watch(searchBarPositionProvider);
    final settingsReverse = searchBarPosition == SearchBarPosition.bottom;
    final effectiveReverse = reverse ?? settingsReverse;

    final effectiveChildren = [
      const SizedBox(height: 8),
      ?notice,
      ...[
        ...children,
      ].intersperse(
        const Divider(thickness: 1),
      ),
      SizedBox(
        height: MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: effectiveReverse
          ? effectiveChildren.reversed.toList()
          : effectiveChildren,
    );
  }
}

class DefaultQueryActionsSection extends StatelessWidget {
  const DefaultQueryActionsSection({
    super.key,
    required this.onTagAdded,
    this.titleTrailing,
  });

  final Widget Function()? titleTrailing;
  final void Function(String) onTagAdded;

  @override
  Widget build(BuildContext context) {
    return QueryActionsSection(
      titleTrailing: titleTrailing,
      onTagAdded: onTagAdded,
      childrenBuilder: () => [],
    );
  }
}

class DefaultFavoriteTagsSection extends ConsumerWidget {
  const DefaultFavoriteTagsSection({
    super.key,
    required this.onTagTap,
  });

  final void Function(FavoriteTag) onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLabel = ref.watch(
      miscDataProvider(kSearchSelectedFavoriteTagLabelKey),
    );

    return FavoriteTagsSection(
      selectedLabel: selectedLabel,
      onTagTap: (value) {
        onTagTap(value);
      },
    );
  }
}

class DefaultSearchHistorySection extends ConsumerWidget {
  const DefaultSearchHistorySection({
    super.key,
    this.reverseScheme = false,
    required this.onHistoryTap,
  });

  final bool reverseScheme;
  final void Function(SearchHistory history) onHistoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(searchHistoryProvider)
        .maybeWhen(
          data: (histories) => Column(
            children: [
              SearchHistorySection(
                reverseScheme: reverseScheme,
                histories: histories.histories,
                onHistoryTap: (history) {
                  onHistoryTap(history);
                },
                onFullHistoryRequested: () {
                  goToSearchHistoryPage(
                    context,
                    onTap: (context, value) {
                      Navigator.of(context).pop();
                      onHistoryTap(value);
                    },
                  );
                },
              ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
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
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fill: 1,
                          ),
                          Text(
                            context.t.search.raw_query,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
