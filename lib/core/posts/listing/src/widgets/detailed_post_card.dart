// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../images/booru_image.dart';
import '../../../../search/search/routes.dart';
import '../../../../settings/providers.dart';
import '../../../../tags/show/providers.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../tags/tag/types.dart';
import '../../../../themes/theme/types.dart';
import '../../../post/types.dart';
import '../types/grid_size.dart';
import 'post_preview.dart';

const _kTagChipHorizontalPadding = 4.0;
const _kTagChipVerticalPadding = 2.0;

// Matches _TagSection bottom padding
const _kTagSectionBottom = 4.0;

// Matches header padding top
const _kHeaderPaddingTop = 4.0;

class DetailedPostCard extends StatefulWidget {
  const DetailedPostCard({
    required this.post,
    required this.config,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  State<DetailedPostCard> createState() => _DetailedPostCardState();
}

class _DetailedPostCardState extends State<DetailedPostCard> {
  var _expanded = false;
  var _canExpand = false;

  // Cached overflow estimation
  bool? _estimatedOverflow;
  double _lastThumbWidth = 0;
  double _lastTagFontSize = 0;

  bool _shouldShowGradient(
    _DetailedCardLayout layout,
  ) {
    if (_canExpand) return true;

    if (_estimatedOverflow == null ||
        layout.thumbWidth != _lastThumbWidth ||
        layout.tagFontSize != _lastTagFontSize) {
      _lastThumbWidth = layout.thumbWidth;
      _lastTagFontSize = layout.tagFontSize;
      _estimatedOverflow = _estimateOverflow(layout);
    }

    return _estimatedOverflow!;
  }

  bool _estimateOverflow(
    _DetailedCardLayout layout,
  ) {
    final availableWidth = layout.contentWidth;
    final availableHeight =
        layout.thumbHeight - layout.estimatedHeaderHeight - _kTagSectionBottom;
    final lineHeight = layout.tagFontSize + _kTagChipVerticalPadding * 2;

    var currentX = 0.0;
    var totalHeight = lineHeight;

    final textStyle = TextStyle(fontSize: layout.tagFontSize);

    for (final name in widget.post.tags) {
      final painter = TextPainter(
        text: TextSpan(text: name, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final tagWidth = painter.width + _kTagChipHorizontalPadding * 2;
      painter.dispose();

      if (currentX + tagWidth > availableWidth) {
        totalHeight += lineHeight;
        currentX = tagWidth;
      } else {
        currentX += tagWidth;
      }

      if (totalHeight > availableHeight) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) => Consumer(
        builder: (context, ref, _) {
          final gridSize = ref.watch(
            imageListingSettingsProvider.select((v) => v.gridSize),
          );
          final layout = _DetailedCardLayout.fromGridSize(
            gridSize,
            constraints.maxWidth,
          );

          return Container(
            height: _expanded ? null : layout.thumbHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onTap,
                  child: _Thumbnail(
                    post: widget.post,
                    config: widget.config,
                    imageUrl: widget.imageUrl,
                    layout: layout,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      NotificationListener<ScrollMetricsNotification>(
                        onNotification: (notification) {
                          if (_expanded) return false;
                          final overflow =
                              notification.metrics.maxScrollExtent > 0;
                          if (overflow != _canExpand) {
                            setState(() => _canExpand = overflow);
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DefaultPostPreviewHeader(
                                post: widget.post,
                                auth: widget.config,
                                style: TextStyle(
                                  fontSize: layout.headerFontSize,
                                  color: Theme.of(
                                    context,
                                  ).listTileTheme.subtitleTextStyle?.color,
                                ),
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: _kHeaderPaddingTop,
                                  right: 4,
                                ),
                              ),
                              _TagSection(
                                post: widget.post,
                                auth: widget.config,
                                fontSize: layout.tagFontSize,
                              ),
                              if (_expanded)
                                _CollapseButton(
                                  color: colorScheme.hintColor,
                                  onTap: () =>
                                      setState(() => _expanded = false),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!_expanded && _shouldShowGradient(layout))
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _ExpandOverlay(
                            color: colorScheme.surfaceContainerLow,
                            hintColor: colorScheme.hintColor,
                            height: layout.thumbHeight * 0.45,
                            onTap: () => setState(() => _expanded = true),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExpandOverlay extends StatelessWidget {
  const _ExpandOverlay({
    required this.color,
    required this.hintColor,
    required this.height,
    required this.onTap,
  });

  final Color color;
  final Color hintColor;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Icon(
                Icons.expand_less,
                size: 20,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.post,
    required this.config,
    required this.imageUrl,
    required this.layout,
  });

  final Post post;
  final BooruConfigAuth config;
  final String imageUrl;
  final _DetailedCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: layout.thumbWidth,
      height: layout.thumbHeight,
      child: BooruImage(
        config: config,
        imageUrl: imageUrl,
        placeholderUrl: post.thumbnailImageUrl,
        borderRadius: BorderRadius.circular(4),
        aspectRatio: post.aspectRatio,
        forceCover: true,
        fit: BoxFit.cover,
      ),
    );
  }
}

double detailedCardHeight(GridSize size) =>
    _DetailedCardLayout.fromGridSize(size, _kReferenceWidth).thumbHeight;

// Reference width used for placeholder height estimation (typical mobile)
const _kReferenceWidth = 400.0;

class _DetailedCardLayout {
  factory _DetailedCardLayout.fromGridSize(GridSize size, double screenWidth) {
    final config = switch (size) {
      GridSize.micro => (frac: 0.14, ar: 0.85, pad: 4.0, tag: 12.0, hdr: 11.0),
      GridSize.tiny => (frac: 0.18, ar: 0.80, pad: 6.0, tag: 12.0, hdr: 11.0),
      GridSize.small => (frac: 0.22, ar: 0.85, pad: 8.0, tag: 12.0, hdr: 11.0),
      GridSize.normal => (frac: 0.28, ar: 0.82, pad: 8.0, tag: 13.0, hdr: 12.0),
      GridSize.large => (frac: 0.35, ar: 0.82, pad: 10.0, tag: 14.0, hdr: 13.0),
    };

    final thumbWidth = screenWidth * config.frac;
    final thumbHeight = thumbWidth / config.ar;

    return _DetailedCardLayout._(
      cardWidth: screenWidth,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      thumbWidthFraction: config.frac,
      aspectRatio: config.ar,
      padding: config.pad,
      tagFontSize: config.tag,
      headerFontSize: config.hdr,
    );
  }

  const _DetailedCardLayout._({
    required this.cardWidth,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.thumbWidthFraction,
    required this.aspectRatio,
    required this.padding,
    required this.tagFontSize,
    required this.headerFontSize,
  });

  double get estimatedHeaderHeight => headerFontSize * 2 + _kHeaderPaddingTop;
  double get contentWidth => cardWidth - thumbWidth;

  final double cardWidth;
  final double thumbWidth;
  final double thumbHeight;
  final double thumbWidthFraction;
  final double aspectRatio;
  final double padding;
  final double tagFontSize;
  final double headerFontSize;
}

class _TagSection extends ConsumerWidget {
  const _TagSection({
    required this.post,
    required this.auth,
    required this.fontSize,
  });

  final Post post;
  final BooruConfigAuth auth;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (auth, post);

    final hintColor = Theme.of(context).colorScheme.hintColor;

    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: fontSize),
      child: Padding(
        padding: const EdgeInsets.only(bottom: _kTagSectionBottom),
        child: switch (ref.watch(showTagsProvider(params))) {
          AsyncData(:final value) when value.isNotEmpty => Wrap(
            children: [
              for (final tag in value) _DetailedTagChip(tag: tag, auth: auth),
            ],
          ),
          AsyncData() => const SizedBox.shrink(),
          _ => Wrap(
            children: [
              for (var i = 0; i < post.tags.length.clamp(0, 8); i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kTagChipHorizontalPadding,
                    vertical: _kTagChipVerticalPadding,
                  ),
                  child: Container(
                    width: 40.0 + (i * 7 % 30),
                    height: fontSize + 4,
                    decoration: BoxDecoration(
                      color: hintColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        },
      ),
    );
  }
}

class _DetailedTagChip extends ConsumerWidget {
  const _DetailedTagChip({
    required this.tag,
    required this.auth,
  });

  final Tag tag;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(
      tagColorProvider((auth, tag.category.name)),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => goToSearchPage(ref, tag: tag.name),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kTagChipHorizontalPadding,
            vertical: _kTagChipVerticalPadding,
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              color: color,
              fontSize: DefaultTextStyle.of(context).style.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
