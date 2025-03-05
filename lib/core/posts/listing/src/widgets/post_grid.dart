// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../_internal/default_image_grid_item.dart';
import '../_internal/post_grid_config_icon_button.dart';
import '../_internal/raw_post_grid.dart';
import '../_internal/sliver_post_grid.dart';
import 'blacklist_controls.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';

typedef IndexedSelectableWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
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
  });

  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;
  final bool safeArea;
  final String? blacklistedIdString;
  final MultiSelectController<T>? multiSelectController;
  final PostGridController<T> controller;
  final IndexedSelectableWidgetBuilder<T>? itemBuilder;
  final Widget? body;

  @override
  State<PostGrid<T>> createState() => _PostGridState();
}

class _PostGridState<T extends Post> extends State<PostGrid<T>> {
  late final AutoScrollController _autoScrollController =
      widget.scrollController ?? AutoScrollController();
  late final _multiSelectController =
      widget.multiSelectController ?? MultiSelectController<T>();

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
    return _InheritedPostGridController(
      controller: widget.controller,
      child: _InheritedAutoScrollController(
        controller: _autoScrollController,
        child: LayoutBuilder(
          builder: (context, constraints) => RawPostGrid(
            sliverHeaders: [
              ...widget.sliverHeaders ?? [],
              _DisableGridItemHeroOnPop(disableHero: _disableHero),
            ],
            scrollController: _autoScrollController,
            footer: Consumer(
              builder: (_, ref, __) {
                final booruBuilder = ref.watch(currentBooruBuilderProvider);

                final multiSelectActions =
                    booruBuilder?.multiSelectionActionsBuilder?.call(
                  context,
                  _multiSelectController,
                );

                return multiSelectActions ?? const SizedBox.shrink();
              },
            ),
            blacklistedIdString: widget.blacklistedIdString,
            multiSelectController: _multiSelectController,
            controller: widget.controller,
            safeArea: widget.safeArea,
            gridHeader: _GridHeader<T>(
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
                  constraints: constraints,
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

class _PageIndicator<T extends Post> extends ConsumerWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = _InheritedPostGridController.of<T>(context);
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
  final MultiSelectController<T> multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHeader = ref.watch(
      imageListingSettingsProvider.select((v) => v.showPostListConfigHeader),
    );

    if (!showHeader) return const SizedBox.shrink();

    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageGridPadding),
    );

    final controller = _InheritedPostGridController.of<T>(context);

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
                    blacklistControls: BlacklistControls(
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

class _SliverGrid<T extends Post> extends ConsumerWidget {
  const _SliverGrid({
    required this.constraints,
    required this.itemBuilder,
    required this.postController,
    super.key,
  });

  final BoxConstraints? constraints;
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
      constraints: constraints,
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

class _InheritedPostGridController<T extends Post> extends InheritedWidget {
  const _InheritedPostGridController({
    required this.controller,
    required super.child,
    super.key,
  });

  final PostGridController<T> controller;

  static PostGridController<T> of<T extends Post>(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedPostGridController<T>>();

    if (result == null) {
      throw FlutterError(
        'No PostGridController found in context. Make sure to wrap your widget with PostGrid.',
      );
    }

    return result.controller;
  }

  @override
  bool updateShouldNotify(_InheritedPostGridController<T> oldWidget) {
    return controller != oldWidget.controller;
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
