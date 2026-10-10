// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../configs/manage/providers.dart';
import '../../../../http/client/providers.dart';
import '../../../../images/providers.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/show/providers.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../tags/tag/types.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/types.dart';
import '../../../post/widgets.dart';
import '../../../rating/types.dart';
import '../../../sources/types.dart';

const _maxSize = Size(400, 120);
const _previewKey = LogicalKeyboardKey.keyI;

const _iconTrigger = AnchorTriggerMode.hover(
  waitDuration: Duration(milliseconds: 150),
  requirePointerMovement: true,
);

class DefaultTagListPrevewTooltip extends ConsumerWidget {
  const DefaultTagListPrevewTooltip({
    super.key,
    required this.config,
    required this.post,
    required this.child,
  });

  final BooruConfigAuth config;
  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostListPrevewTooltip(
      overlayChildBuilder: (context, adjustedMaxWidth, adjustedMaxHeight) =>
          PostTagPreviewContainer(
            post: post,
            auth: config,
            maxWidth: adjustedMaxWidth,
            maxHeight: adjustedMaxHeight,
            builder: (context, tags) => PostPreviewPopover(
              tags: tags,
              auth: config,
              header: DefaultPostPreviewHeader(
                post: post,
                auth: config,
              ),
            ),
          ),

      child: child,
    );
  }
}

class DefaultPostPreviewHeader extends ConsumerWidget {
  const DefaultPostPreviewHeader({
    super.key,
    required this.post,
    required this.auth,
    this.extraWidgets,
    this.style,
  });

  final Post post;
  final BooruConfigAuth auth;
  final TextStyle? style;
  final List<Widget>? extraWidgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Kurumi.themeOf(context);
    final dio = ref.watch(faviconDioProvider);
    final style =
        this.style ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.listTileTheme.subtitleTextStyle?.color,
          fontSize: 11,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 350;

          final leftSideWidgets = [
            if (post.createdAt case final createdAt?)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: DateTooltip(
                  date: createdAt,
                  child: TimePulse(
                    initial: createdAt,
                    updateInterval: const Duration(minutes: 1),
                    builder: (context, _) => Text(
                      createdAt.fuzzify(
                        locale: Localizations.localeOf(context),
                      ),
                      style: style,
                    ),
                  ),
                ),
              ),
            ...?extraWidgets,
          ];

          final rightSideWidgets = [
            if (post.rating case final rating when rating != Rating.unknown)
              Text(
                rating.toShortString().toUpperCase(),
                style: style,
              ),

            if (Filesize.tryParse(post.fileSize) case final size?)
              Text(
                size,
                style: style,
              ),

            if (post.format case final format when format.isNotEmpty)
              Text(
                '.$format',
                style: style,
              ),

            if (post.width > 0 && post.height > 0)
              Text(
                '${post.width.toInt()}x${post.height.toInt()}',
                style: style,
              ),

            if (post.source case final WebSource source
                when source.faviconUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                  size: 14,
                  dio: dio,
                  cacheManager: ref.watch(defaultImageCacheManagerProvider),
                ),
              ),
          ];

          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftSideWidgets.isNotEmpty)
                  Row(
                    spacing: 4,
                    children: leftSideWidgets,
                  ),

                if (rightSideWidgets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2),
                    child: Row(
                      spacing: 4,
                      children: rightSideWidgets,
                    ),
                  ),
              ],
            );
          } else {
            return Row(
              spacing: 4,
              children: [
                ...leftSideWidgets,
                const Spacer(),
                ...rightSideWidgets,
              ],
            );
          }
        },
      ),
    );
  }
}

class PostListPrevewTooltip extends ConsumerStatefulWidget {
  const PostListPrevewTooltip({
    super.key,
    required this.overlayChildBuilder,
    required this.child,
  });

  final Widget child;
  final Widget Function(
    BuildContext context,
    double adjustedMaxWidth,
    double adjustedMaxHeight,
  )
  overlayChildBuilder;

  @override
  ConsumerState<PostListPrevewTooltip> createState() =>
      _PostListPrevewTooltipState();
}

class _PostListPrevewTooltipState extends ConsumerState<PostListPrevewTooltip> {
  final _controller = AnchorController();
  final _hovered = ValueNotifier(false);

  @override
  void dispose() {
    HardwareKeyboard.instance
      ..removeHandler(_hideOnKey)
      ..removeHandler(_toggleOnKey);
    _controller.dispose();
    _hovered.dispose();
    super.dispose();
  }

  // A hover preview is for the mouse. Once keys take over it would only hide
  // the control they move focus to.
  bool _hideOnKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey != _previewKey) {
      _controller.hide();
    }
    return false;
  }

  bool _toggleOnKey(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    if (event is! KeyDownEvent || event.logicalKey != _previewKey) return false;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed) {
      return false;
    }
    if (_isTyping()) return false;

    _controller.toggle();
    return true;
  }

  static bool _isTyping() =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  void _handleEnter(PointerEnterEvent _) {
    _hovered.value = true;
    HardwareKeyboard.instance.addHandler(_toggleOnKey);
  }

  void _handleExit(PointerExitEvent _) {
    _hovered.value = false;
    HardwareKeyboard.instance.removeHandler(_toggleOnKey);
  }

  @override
  Widget build(BuildContext context) {
    final enableTooltip = ref.watch(
      currentReadOnlyBooruConfigProvider.select(
        (value) => value.tooltipDisplayMode?.isEnabled ?? true,
      ),
    );

    if (!enableTooltip) return widget.child;

    // Tiles fill the grid, so hovering one says nothing about wanting its
    // preview. The badge gives that intent a target of its own.
    return MouseRegion(
      opaque: false,
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 4,
            right: 4,
            child: _InfoBadge(
              hovered: _hovered,
              controller: _controller,
              child: _buildPopover(
                child: const ImageOverlayIcon(icon: Symbols.info),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopover({required Widget child}) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final screenWidth = MediaQuery.widthOf(context);
    final adjustedMaxWidth = min(
      _maxSize.width,
      screenWidth - 32,
    );
    final adjustedMaxHeight = _maxSize.height;

    return AnchorPopover(
      controller: _controller,
      onShow: () => HardwareKeyboard.instance.addHandler(_hideOnKey),
      onHide: () => HardwareKeyboard.instance.removeHandler(_hideOnKey),
      overlayHeight: adjustedMaxHeight,
      overlayWidth: adjustedMaxWidth,
      triggerMode: _iconTrigger,
      viewPadding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 48, // To avoid app bar
        bottom: 8,
      ),
      placement: Placement.top,
      offset: const Offset(0, -4),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: colorScheme.surfaceContainerHigh,
      arrowSize: const Size(16, 8),
      border: BorderSide(
        color: colorScheme.outlineVariant,
        width: 1.5,
      ),
      overlayBuilder: (context) => widget.overlayChildBuilder(
        context,
        adjustedMaxWidth,
        adjustedMaxHeight,
      ),
      child: child,
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.hovered,
    required this.controller,
    required this.child,
  });

  final ValueNotifier<bool> hovered;
  final AnchorController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selection = SelectionMode.maybeOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([hovered, controller, ?selection]),
      builder: (context, child) {
        final selecting = selection?.isActive ?? false;
        final visible = !selecting && (hovered.value || controller.isShowing);

        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 120),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggle,
        child: child,
      ),
    );
  }
}

class PostTagPreviewContainer extends ConsumerWidget {
  const PostTagPreviewContainer({
    super.key,
    required this.post,
    required this.auth,
    required this.maxWidth,
    required this.maxHeight,
    required this.builder,
  });

  final BooruConfigAuth auth;
  final Post post;
  final double maxWidth;
  final double maxHeight;
  final Widget Function(BuildContext context, List<Tag> tags) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (auth, post);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      ),
      child: switch (ref.watch(showTagsProvider(params))) {
        AsyncData(:final value) when value.isNotEmpty => builder(
          context,
          value,
        ),
        AsyncLoading() => Container(
          margin: const EdgeInsets.all(16),
          height: 16,
          width: 16,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
        AsyncError(:final error) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            error.toString(),
          ),
        ),
        _ => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'No tags available'.hc,
          ),
        ),
      },
    );
  }
}

class PostPreviewPopover extends StatefulWidget {
  const PostPreviewPopover({
    super.key,
    required this.tags,
    required this.auth,
    this.header,
  });

  final List<Tag> tags;
  final BooruConfigAuth auth;
  final Widget? header;

  @override
  State<PostPreviewPopover> createState() => _PostPreviewPopoverState();
}

class _PostPreviewPopoverState extends State<PostPreviewPopover> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?widget.header,
        Flexible(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(4),
                child: Wrap(
                  spacing: 2,
                  children: [
                    for (final tag in widget.tags)
                      TagPreviewChip(
                        tag: tag,
                        auth: widget.auth,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TagPreviewChip extends ConsumerWidget {
  const TagPreviewChip({
    super.key,
    required this.tag,
    required this.auth,
  });

  final Tag tag;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(
      tagColorProvider(
        (auth, tag.category.name),
      ),
    );

    return GestureDetector(
      onTap: () => goToSearchPage(ref, tag: tag.name),
      child: KurumiHoverAwareContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
