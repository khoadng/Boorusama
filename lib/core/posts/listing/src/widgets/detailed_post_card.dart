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
import 'expand_collapse_widgets.dart';
import 'post_preview.dart';

const _kTagChipHorizontalPadding = 4.0;
const _kTagChipVerticalPadding = 2.0;
const _kTagSectionBottom = 4.0;
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

  void _collapse() => collapseAndScrollBack(
    context,
    () => setState(() => _expanded = false),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) => Consumer(
        builder: (context, ref, _) {
          final gridSize = ref.watch(
            imageListingSettingsProvider.select((v) => v.gridSize),
          );
          final compact = ref.watch(
            imageListingSettingsProvider.select(
              (v) => v.itemOverflowMode.isActive,
            ),
          );
          final layout = DetailedCardLayout.fromGridSize(
            gridSize,
            constraints.maxWidth,
          );

          final content = Row(
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
                      CollapseButton(
                        color: colorScheme.hintColor,
                        onTap: _collapse,
                      ),
                  ],
                ),
              ),
            ],
          );

          if (!compact) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: content,
            );
          }

          return Container(
            height: _expanded ? null : layout.thumbHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                NotificationListener<ScrollMetricsNotification>(
                  onNotification: (notification) {
                    if (_expanded) return false;
                    final overflow = notification.metrics.maxScrollExtent > 0;
                    if (overflow != _canExpand) {
                      setState(() => _canExpand = overflow);
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: content,
                  ),
                ),
                if (!_expanded && _canExpand)
                  Positioned(
                    left: layout.thumbWidth,
                    right: 0,
                    bottom: 0,
                    child: ExpandOverlay(
                      color: colorScheme.surfaceContainerLow,
                      hintColor: colorScheme.hintColor,
                      height: layout.thumbHeight * 0.45,
                      onTap: () => setState(() => _expanded = true),
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
  final DetailedCardLayout layout;

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
    DetailedCardLayout.fromGridSize(size, _kReferenceWidth).thumbHeight;

// Reference width used for placeholder height estimation (typical mobile)
const _kReferenceWidth = 400.0;

class DetailedCardLayout {
  factory DetailedCardLayout.fromGridSize(GridSize size, double cardWidth) {
    final config = switch (size) {
      GridSize.micro => (frac: 0.14, ar: 0.85, pad: 4.0, tag: 12.0, hdr: 11.0),
      GridSize.tiny => (frac: 0.18, ar: 0.80, pad: 6.0, tag: 12.0, hdr: 11.0),
      GridSize.small => (frac: 0.22, ar: 0.85, pad: 8.0, tag: 12.0, hdr: 11.0),
      GridSize.normal => (frac: 0.28, ar: 0.82, pad: 8.0, tag: 13.0, hdr: 12.0),
      GridSize.large => (frac: 0.35, ar: 0.82, pad: 10.0, tag: 14.0, hdr: 13.0),
    };

    final thumbWidth = cardWidth * config.frac;
    final thumbHeight = thumbWidth / config.ar;

    return DetailedCardLayout._(
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      padding: config.pad,
      tagFontSize: config.tag,
      headerFontSize: config.hdr,
    );
  }

  const DetailedCardLayout._({
    required this.thumbWidth,
    required this.thumbHeight,
    required this.padding,
    required this.tagFontSize,
    required this.headerFontSize,
  });

  final double thumbWidth;
  final double thumbHeight;
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
