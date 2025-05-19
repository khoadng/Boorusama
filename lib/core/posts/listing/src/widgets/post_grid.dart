// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../configs/routes.dart';
import '../../../../configs/src/create/search_blacklist.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../_internal/default_image_grid_item.dart';
import '../_internal/post_grid_config_icon_button.dart';
import '../_internal/raw_post_grid.dart';
import '../_internal/sliver_post_grid.dart';
import 'blacklist_controls.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';
import 'post_scope.dart';

typedef IndexedSelectableWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController multiSelectController,
  AutoScrollController autoScrollController,
  bool useHero,
);

class PostGrid<T extends Post> extends StatefulWidget {
  const PostGrid({
    required this.controller,
    super.key,
    this.sliverHeaders,
    this.scrollController,
    this.blacklistedIdString,
    this.multiSelectController,
    this.safeArea = true,
    this.itemBuilder,
    this.body,
    this.header,
    this.multiSelectActions,
    this.scrollToTopButton,
    this.enablePullToRefresh,
  });

  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;
  final bool safeArea;
  final String? blacklistedIdString;
  final MultiSelectController? multiSelectController;
  final PostGridController<T> controller;
  final IndexedSelectableWidgetBuilder<T>? itemBuilder;
  final Widget? body;
  final Widget? header;
  final Widget? multiSelectActions;
  final Widget? scrollToTopButton;
  final bool? enablePullToRefresh;

  @override
  State<PostGrid<T>> createState() => _PostGridState();
}

class _PostGridState<T extends Post> extends State<PostGrid<T>> {
  late final AutoScrollController _autoScrollController =
      widget.scrollController ?? AutoScrollController();
  late final _multiSelectController =
      widget.multiSelectController ?? MultiSelectController();

  final ValueNotifier<bool> _disableHero = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    _disableHero.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAutoScrollController(
      controller: _autoScrollController,
      child: RawPostGrid(
        sliverHeaders: [
          ...widget.sliverHeaders ?? [],
          _DisableGridItemHeroOnPop(disableHero: _disableHero),
        ],
        scrollController: _autoScrollController,
        footer: Consumer(
          builder: (_, ref, __) {
            final booruBuilder =
                ref.watch(booruBuilderProvider(ref.watchConfigAuth));

            final multiSelectActions = widget.multiSelectActions ??
                booruBuilder?.multiSelectionActionsBuilder?.call(
                  context,
                  _multiSelectController,
                  widget.controller,
                );

            return multiSelectActions ?? const SizedBox.shrink();
          },
        ),
        blacklistedIdString: widget.blacklistedIdString,
        multiSelectController: _multiSelectController,
        controller: widget.controller,
        safeArea: widget.safeArea,
        enablePullToRefresh: widget.enablePullToRefresh ?? true,
        gridHeader: widget.header ??
            _GridHeader<T>(
              multiSelectController: _multiSelectController,
            ),
        topPageIndicator: Consumer(
          builder: (_, ref, __) {
            final visibleAtTop = ref.watch(
              imageListingSettingsProvider
                  .select((v) => v.pageIndicatorPosition.isVisibleAtTop),
            );

            return visibleAtTop
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PageIndicator<T>(),
                  )
                : const SizedBox.shrink();
          },
        ),
        bottomPageIndicator: Consumer(
          builder: (_, ref, __) {
            final visibleAtBottom = ref.watch(
              imageListingSettingsProvider
                  .select((v) => v.pageIndicatorPosition.isVisibleAtBottom),
            );

            return visibleAtBottom
                ? SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: _PageIndicator<T>(),
                  )
                : const SizedBox.shrink();
          },
        ),
        scrollToTopButton: widget.scrollToTopButton ??
            PostGridScrollToTopButton(
              controller: widget.controller,
              multiSelectController: _multiSelectController,
              autoScrollController: _autoScrollController,
            ),
        onNextPage: () => _goToNextPage(
          widget.controller,
          _autoScrollController,
        ),
        onPreviousPage: () => _goToPreviousPage(
          widget.controller,
          _autoScrollController,
        ),
        body: widget.body ??
            _SliverGrid(
              postController: widget.controller,
              itemBuilder: (context, index) => ValueListenableBuilder(
                valueListenable: _disableHero,
                builder: (_, disableHero, __) =>
                    widget.itemBuilder?.call(
                      context,
                      index,
                      _multiSelectController,
                      _autoScrollController,
                      !disableHero,
                    ) ??
                    DefaultImageGridItem(
                      index: index,
                      multiSelectController: _multiSelectController,
                      autoScrollController: _autoScrollController,
                      controller: widget.controller,
                      useHero: !disableHero,
                    ),
              ),
            ),
      ),
    );
  }
}

class PostGridScrollToTopButton extends StatelessWidget {
  const PostGridScrollToTopButton({
    required this.controller,
    required this.multiSelectController,
    required this.autoScrollController,
    super.key,
    this.bottomPadding,
  });

  final PostGridController controller;
  final MultiSelectController multiSelectController;
  final AutoScrollController autoScrollController;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveBottomPadding = bottomPadding ?? 0;

    return _ScrollToTopPositioned(
      child: ValueListenableBuilder(
        valueListenable: multiSelectController.multiSelectNotifier,
        builder: (_, multiSelect, __) => Padding(
          padding: multiSelect
              ? EdgeInsets.only(bottom: 60 + effectiveBottomPadding)
              : EdgeInsets.only(bottom: effectiveBottomPadding),
          child: ScrollToTop(
            scrollController: autoScrollController,
            onBottomReached: () {
              if (controller.pageMode == PageMode.infinite &&
                  controller.hasMore) {
                controller.fetchMore();
              }
            },
            child: BooruScrollToTopButton(
              onPressed: () {
                autoScrollController.jumpTo(0);
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _goToNextPage(
  PostGridController<Post> controller,
  AutoScrollController scrollController,
) async {
  await controller.goToNextPage();
  scrollController.jumpTo(0);
}

Future<void> _goToPreviousPage(
  PostGridController<Post> controller,
  AutoScrollController scrollController,
) async {
  await controller.goToPreviousPage();
  scrollController.jumpTo(0);
}

class _ScrollToTopPositioned extends ConsumerWidget {
  const _ScrollToTopPositioned({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final padding = max(viewPadding.bottom, viewInsets.bottom);

    final bottomPadding = padding + 8;

    return Positioned(
      right: 12,
      bottom: bottomPadding,
      child: child,
    );
  }
}

class _PageIndicator<T extends Post> extends ConsumerWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = PostScope.of<T>(context);
    final scrollController = _InheritedAutoScrollController.of(context);

    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((v) => v.postsPerPage),
    );

    return ValueListenableBuilder(
      valueListenable: controller.count,
      builder: (_, value, __) => ValueListenableBuilder(
        valueListenable: controller.pageNotifier,
        builder: (_, page, __) => PageSelector(
          totalResults: value,
          itemPerPage: postsPerPage,
          currentPage: page,
          onPrevious: controller.hasPreviousPage()
              ? () => _goToPreviousPage(
                    controller,
                    scrollController,
                  )
              : null,
          onNext: controller.hasNextPage()
              ? () => _goToNextPage(
                    controller,
                    scrollController,
                  )
              : null,
          onPageSelect: (page) async {
            await controller.jumpToPage(page);
            scrollController.jumpTo(0);
          },
        ),
      ),
    );
  }
}

final _expandedProvider = StateProvider.autoDispose<bool?>((ref) => null);

class _GridHeader<T extends Post> extends ConsumerWidget {
  const _GridHeader({
    required this.multiSelectController,
    this.axis = Axis.horizontal,
    super.key,
  });

  final Axis axis;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHeader = ref.watch(
      imageListingSettingsProvider.select((v) => v.showPostListConfigHeader),
    );

    if (!showHeader) return const SizedBox.shrink();

    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageGridPadding),
    );

    final controller = PostScope.of<T>(context);

    return ValueListenableBuilder(
      valueListenable: controller.hasBlacklist,
      builder: (__, hasBlacklist, _) {
        return ValueListenableBuilder(
          valueListenable: controller.tagCounts,
          builder: (__, tagCounts, _) {
            return ValueListenableBuilder(
              valueListenable: controller.activeFilters,
              builder: (__, activeFilters, _) {
                final expand = ref.watch(_expandedProvider);
                final expandNotifier = ref.watch(_expandedProvider.notifier);

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: imageGridPadding,
                  ),
                  child: PostListConfigurationHeader(
                    blacklistControls: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlacklistControls(
                          hiddenTags: activeFilters.keys
                              .map(
                                (e) => (
                                  name: e,
                                  count: tagCounts[e]?.length ?? 0,
                                  active: activeFilters[e] ?? false,
                                ),
                              )
                              .where((e) => e.count > 0)
                              .toList(),
                          onDisableAll: () {
                            controller.disableAllTags();
                          },
                          onEnableAll: () {
                            controller.enableAllTags();
                          },
                          onChanged: (tag, hide) {
                            if (hide) {
                              controller.enableTag(tag);
                            } else {
                              controller.disableTag(tag);
                            }
                          },
                          axis: axis,
                        ),
                        const _BlacklistedTagsInterceptedNotice(),
                      ],
                    ),
                    axis: axis,
                    postCount: controller.total,
                    initiallyExpanded: axis == Axis.vertical || expand == true,
                    onExpansionChanged: (value) => expandNotifier.state = value,
                    hasBlacklist: hasBlacklist,
                    trailing: axis == Axis.horizontal
                        ? PostGridConfigIconButton(
                            multiSelectController: multiSelectController,
                            postController: controller,
                          )
                        : null,
                    hiddenCount: tagCounts.totalNonDuplicatesPostCount,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BlacklistedTagsInterceptedNotice extends ConsumerWidget {
  const _BlacklistedTagsInterceptedNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watchConfig;
    final enable = config.blacklistConfigs?.enable;
    final mode = config.blacklistConfigs?.combinationMode;

    if (enable != true) {
      return const SizedBox.shrink();
    }

    if (mode == null) {
      return const SizedBox.shrink();
    }

    final blacklistConfigsMode = BlacklistCombinationMode.fromString(mode);

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
          children: [
            if (blacklistConfigsMode == BlacklistCombinationMode.replace)
              const TextSpan(
                text: 'Replaced by ',
              )
            else
              const TextSpan(
                text: 'Merged with ',
              ),
            TextSpan(
              text: "Profile's blacklist",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  goToUpdateBooruConfigPage(
                    context,
                    config: config,
                    initialTab: 'search',
                  );
                },
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const TextSpan(
              text: ' settings.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverGrid<T extends Post> extends ConsumerWidget {
  const _SliverGrid({
    required this.itemBuilder,
    required this.postController,
    super.key,
  });

  final IndexedWidgetBuilder itemBuilder;
  final PostGridController<T> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridPadding),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridAspectRatio = ref.watch(
      imageListingSettingsProvider
          .select((value) => value.imageGridAspectRatio),
    );
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );

    final imageGridBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );

    return SliverPostGrid(
      itemBuilder: itemBuilder,
      postController: postController,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      size: gridSize,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      postsPerPage: postsPerPage,
      borderRadius: BorderRadius.circular(imageGridBorderRadius),
    );
  }
}

class _DisableGridItemHeroOnPop extends ConsumerWidget {
  const _DisableGridItemHeroOnPop({
    required this.disableHero,
  });

  final ValueNotifier<bool> disableHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kEnableHeroTransition) {
      return const SliverSizedBox.shrink();
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          disableHero.value = true;
        }
      },
      child: const SliverSizedBox.shrink(),
    );
  }
}

class _InheritedAutoScrollController extends InheritedWidget {
  const _InheritedAutoScrollController({
    required this.controller,
    required super.child,
  });

  final AutoScrollController controller;

  static AutoScrollController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedAutoScrollController>();

    if (result == null) {
      throw FlutterError(
        'No AutoScrollController found in context. Make sure to wrap your widget with AutoScrollController.',
      );
    }

    return result.controller;
  }

  @override
  bool updateShouldNotify(_InheritedAutoScrollController oldWidget) {
    return controller != oldWidget.controller;
  }
}
