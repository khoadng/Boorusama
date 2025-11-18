// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../configs/manage/providers.dart';
import '../../../../http/client/providers.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/show/providers.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../tags/tag/types.dart';
import '../../../../widgets/hover_aware_container.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/types.dart';
import '../../../rating/types.dart';
import '../../../sources/types.dart';

const _maxSize = Size(400, 120);

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
    final theme = Theme.of(context);
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

class PostListPrevewTooltip extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.sizeOf(context);
    final adjustedMaxWidth = min(
      _maxSize.width,
      screenSize.width - 32,
    );
    final adjustedMaxHeight = _maxSize.height;
    final enableTooltip = ref.watch(
      currentReadOnlyBooruConfigProvider.select(
        (value) => value.tooltipDisplayMode?.isEnabled ?? true,
      ),
    );

    return AnchorPopover(
      enabled: enableTooltip,
      overlayHeight: adjustedMaxHeight,
      overlayWidth: adjustedMaxWidth,
      triggerMode: const AnchorTriggerMode.hover(
        waitDuration: Duration(milliseconds: 1500),
      ),
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
      overlayBuilder: (context) => overlayChildBuilder(
        context,
        adjustedMaxWidth,
        adjustedMaxHeight,
      ),
      child: child,
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
      child: HoverAwareContainer(
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
