// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../foundation/html.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../configs/create/routes.dart';
import '../../../../configs/search/types.dart';
import '../../../../errors/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/types.dart';
import '../../widgets.dart';
import '../_internal/raw_post_grid.dart';
import '../_internal/sliver_post_grid.dart';
import '../providers/internal_providers.dart';
import '../types/page_mode.dart';
import 'infinite_scroll_listener.dart';
import 'post_grid_controller.dart';

typedef IndexedSelectableWidgetBuilder<T extends Post> =
    Widget Function(
      BuildContext context,
      int index,
      AutoScrollController autoScrollController,
      bool useHero,
    );

class PostGrid<T extends Post> extends ConsumerStatefulWidget {
  const PostGrid({
    required this.controller,
    super.key,
    this.sliverHeaders,
    this.scrollController,
    this.blacklistedIdString,
    this.selectionModeController,
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
  final SelectionModeController? selectionModeController;
  final PostGridController<T> controller;
  final IndexedSelectableWidgetBuilder<T>? itemBuilder;
  final Widget? body;
  final Widget? header;
  final Widget? multiSelectActions;
  final Widget? scrollToTopButton;
  final bool? enablePullToRefresh;

  @override
  ConsumerState<PostGrid<T>> createState() => _PostGridState();
}

class _PostGridState<T extends Post> extends ConsumerState<PostGrid<T>> {
  late final AutoScrollController _autoScrollController =
      widget.scrollController ?? AutoScrollController();
  late final SelectionModeController _selectionModeController;

  final ValueNotifier<bool> _disableHero = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _selectionModeController =
        widget.selectionModeController ?? SelectionModeController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.selectionModeController == null) {
      _selectionModeController.dispose();
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
        options: PostGridOptions(
          cacheExtent: ref.watch(gridCacheExtentProvider),
          hapticFeedbackLevel: ref.watch(hapticFeedbackLevelProvider),
          gridSize: ref.watch(
            imageListingSettingsProvider.select((v) => v.gridSize),
          ),
        ),
        sliverHeaders: [
          ...widget.sliverHeaders ?? [],
          _DisableGridItemHeroOnPop(disableHero: _disableHero),
        ],
        scrollController: _autoScrollController,
        footer: Consumer(
          builder: (_, ref, _) {
            final booruBuilder = ref.watch(
              booruBuilderProvider(ref.watchConfigAuth),
            );

            final multiSelectActions =
                widget.multiSelectActions ??
                booruBuilder?.multiSelectionActionsBuilder?.call(
                  context,
                  _selectionModeController,
                  widget.controller,
                );

            return multiSelectActions ?? const SizedBox.shrink();
          },
        ),
        blacklistedIdString: widget.blacklistedIdString,
        selectionModeController: _selectionModeController,
        selectionOptions: ref.watch(selectionOptionsProvider),
        controller: widget.controller,
        safeArea: widget.safeArea,
        enablePullToRefresh: widget.enablePullToRefresh ?? true,
        gridHeader: widget.header ?? _GridHeader<T>(),
        topPageIndicator: Consumer(
          builder: (_, ref, _) {
            final visibleAtTop = ref.watch(
              imageListingSettingsProvider.select(
                (v) => v.pageIndicatorPosition.isVisibleAtTop,
              ),
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
          builder: (_, ref, _) {
            final visibleAtBottom = ref.watch(
              imageListingSettingsProvider.select(
                (v) => v.pageIndicatorPosition.isVisibleAtBottom,
              ),
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
        scrollToTopButton:
            widget.scrollToTopButton ??
            PostGridScrollToTopButton(
              controller: widget.controller,
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
        body:
            widget.body ??
            _SliverGrid(
              postController: widget.controller,
              itemBuilder: (context, index) => ValueListenableBuilder(
                valueListenable: _disableHero,
                builder: (_, disableHero, _) => GeneralPostContextMenu(
                  index: index,
                  controller: widget.controller,
                  child:
                      widget.itemBuilder?.call(
                        context,
                        index,
                        _autoScrollController,
                        !disableHero,
                      ) ??
                      DefaultImageGridItem(
                        index: index,
                        autoScrollController: _autoScrollController,
                        controller: widget.controller,
                        useHero: !disableHero,
                        config: ref.watchConfigAuth,
                      ),
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
    required this.autoScrollController,
    super.key,
    this.bottomPadding,
  });

  final PostGridController controller;
  final AutoScrollController autoScrollController;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveBottomPadding = bottomPadding ?? 0;
    final selectionModeController = SelectionMode.of(context);

    return _ScrollToTopPositioned(
      child: ListenableBuilder(
        listenable: selectionModeController,
        builder: (_, _) {
          final multiSelect = selectionModeController.isActive;

          return Padding(
            padding: multiSelect
                ? EdgeInsets.only(bottom: 60 + effectiveBottomPadding)
                : EdgeInsets.only(bottom: effectiveBottomPadding),
            child: InfiniteScrollListener(
              scrollController: autoScrollController,
              onBottomReached: () {
                if (controller.pageMode == PageMode.infinite &&
                    controller.hasMore) {
                  controller.fetchMore();
                }
              },
              child: ScrollToTop(
                scrollController: autoScrollController,
                child: BooruScrollToTopButton(
                  onPressed: () {
                    autoScrollController.jumpTo(0);
                  },
                ),
              ),
            ),
          );
        },
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
      builder: (_, value, _) => ValueListenableBuilder(
        valueListenable: controller.pageNotifier,
        builder: (_, page, _) => PageSelector(
          totalResults: value,
          itemPerPage: postsPerPage,
          currentPage: page,
          enableNextButton: PaginationEnablers.notOnLastPage,
          enablePreviousButton: PaginationEnablers.alwaysEnabled,
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
    this.axis = Axis.horizontal,
    super.key,
  });

  final Axis axis;

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
      builder: (_, hasBlacklist, _) {
        return ValueListenableBuilder(
          valueListenable: controller.tagCounts,
          builder: (_, tagCounts, _) {
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
                    ValueListenableBuilder(
                      valueListenable: controller.visibleHiddenTags,
                      builder: (_, hiddenTags, _) => BlacklistControls(
                        hiddenTags: hiddenTags,
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
                    ),
                    const _BlacklistedTagsInterceptedNotice(),
                  ],
                ),
                axis: axis,
                postCount: controller.total,
                initiallyExpanded: axis == Axis.vertical || (expand ?? false),
                onExpansionChanged: (value) => expandNotifier.state = value,
                hasBlacklist: hasBlacklist,
                trailing: axis == Axis.horizontal
                    ? PostGridConfigIconButton(
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
      child: AppHtml(
        data: switch (blacklistConfigsMode) {
          BlacklistCombinationMode.replace =>
            context.t.booru.search.blacklist_overridden.replace_notice,
          BlacklistCombinationMode.merge =>
            context.t.booru.search.blacklist_overridden.merge_notice,
        },
        style: AppHtml.hintStyle(colorScheme),
        onLinkTap: (url, _, _) {
          if (url == 'booru-profiles') {
            goToUpdateBooruConfigPage(
              ref,
              config: config,
              initialTab: 'search',
            );
          }
        },
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
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridAspectRatio = ref.watch(
      imageListingSettingsProvider.select(
        (value) => value.imageGridAspectRatio,
      ),
    );
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );

    final imageGridBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );

    final appErrorTranslator = ref.watch(
      appErrorTranslatorProvider(ref.watchConfigAuth),
    );

    return SliverPostGrid(
      itemBuilder: itemBuilder,
      postController: postController,
      errorTranslator: appErrorTranslator,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      postsPerPage: postsPerPage,
      borderRadius: BorderRadius.circular(imageGridBorderRadius),
      httpErrorActionBuilder: (context, httpStatusCode) => httpStatusCode == 401
          ? const _Error401ActionButton()
          : const SizedBox.shrink(),
    );
  }
}

class _Error401ActionButton extends ConsumerWidget {
  const _Error401ActionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watchConfig;
    final apiKey = config.apiKey;
    final isEmptyApiKey = apiKey == null || apiKey.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
            left: 24,
            right: 24,
          ),
          child: Text(
            isEmptyApiKey
                ? context.t.booru.api_key.auth_error.empty_key_warning
                : context.t.booru.api_key.auth_error.invalid_key_warning,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => goToUpdateBooruConfigPage(
            ref,
            config: config,
            initialTab: 'auth',
          ),
          child: Text(context.t.booru.api_key.auth_error.edit_api_key),
        ),
      ],
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
