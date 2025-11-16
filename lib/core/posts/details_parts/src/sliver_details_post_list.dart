// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../foundation/display/media_query_utils.dart';
import '../../../configs/config/types.dart';
import '../../../images/booru_image.dart';
import '../../details/routes.dart';
import '../../details/types.dart';
import '../../details/widgets.dart';
import '../../listing/types.dart';
import '../../post/tags.dart';
import '../../post/types.dart';
import '../../post/widgets.dart';

class SliverDetailsPostList extends ConsumerWidget {
  const SliverDetailsPostList({
    required this.tag,
    required this.subtitle,
    required this.onTap,
    required this.child,
    super.key,
  });

  final String tag;
  final String subtitle;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: onTap,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RemoveLeftPaddingOnLargeScreen(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      minVerticalPadding: 0,
                      trailing: const Icon(
                        Symbols.arrow_right_alt,
                      ),
                      title: Text(
                        tag.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: child,
          ),
        ],
      ),
    );
  }
}

class SliverPreviewPostGrid<T extends Post> extends StatefulWidget {
  const SliverPreviewPostGrid({
    required this.posts,
    required this.imageUrl,
    required this.auth,
    this.limit,
    super.key,
  });

  final List<T> posts;
  final String Function(T item) imageUrl;
  final BooruConfigAuth auth;
  final PreviewLimit? limit;

  @override
  State<SliverPreviewPostGrid<T>> createState() =>
      _SliverPreviewPostGridState<T>();
}

class _SliverPreviewPostGridState<T extends Post>
    extends State<SliverPreviewPostGrid<T>> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final constraints = PostDetailsSheetConstraints.of(context);
    final effectiveLimit = widget.limit ?? const UnlimitedPreview();

    return switch (effectiveLimit) {
      UnlimitedPreview() => SliverGrid.builder(
        itemCount: widget.posts.length,
        gridDelegate: _getGridDelegate(constraints?.maxWidth),
        itemBuilder: (context, index) => _buildGridItem(index),
      ),
      final LimitedPreview limit => _buildLimitedGrid(
        context,
        constraints,
        limit,
      ),
    };
  }

  Widget _buildLimitedGrid(
    BuildContext context,
    PostDetailsSheetConstraints? constraints,
    LimitedPreview limitConfig,
  ) {
    final crossAxisCount = calculateGridCount(
      constraints?.maxWidth,
      GridSize.small,
    );
    final state = limitConfig.calculateState(
      totalCount: widget.posts.length,
      crossAxisCount: crossAxisCount,
      isExpanded: _isExpanded,
    );

    return MultiSliver(
      children: [
        SliverGrid.builder(
          itemCount: state.displayCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) => _buildGridItem(index),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: _buildExpandButton(context, state),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandButton(BuildContext context, PreviewGridState state) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isExpanded ? Symbols.expand_less : Symbols.expand_more,
              ),
              const SizedBox(width: 4),
              Text(
                _isExpanded
                    ? context.t.post.detail.show_less
                    : context.t.post.detail.show_n_more(
                        n: state.hiddenCount,
                      ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int index) {
    final post = widget.posts[index];

    return Consumer(
      builder: (context, ref, child) {
        return ImageGridItem(
          isGif: post.isGif,
          isAI: post.isAI,
          onTap: () => goToPostDetailsPageFromPosts(
            ref: ref,
            posts: widget.posts,
            initialIndex: index,
            initialThumbnailUrl: post.thumbnailImageUrl,
          ),
          isAnimated: post.isAnimated,
          isTranslated: post.isTranslated,
          image: BooruImage(
            config: widget.auth,
            forceCover: true,
            imageUrl: widget.imageUrl(post),
            placeholderUrl: post.thumbnailImageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class SliverPreviewPostGridPlaceholder extends StatelessWidget {
  const SliverPreviewPostGridPlaceholder({
    super.key,
    this.itemCount = 30,
    this.limit,
  });

  final int itemCount;
  final PreviewLimit? limit;

  @override
  Widget build(BuildContext context) {
    final constraints = PostDetailsSheetConstraints.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveLimit = limit ?? const UnlimitedPreview();

    return switch (effectiveLimit) {
      UnlimitedPreview() => SliverGrid.builder(
        itemCount: itemCount,
        addRepaintBoundaries: false,
        addSemanticIndexes: false,
        addAutomaticKeepAlives: false,
        gridDelegate: _getGridDelegate(constraints?.maxWidth),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      final LimitedPreview limitConfig => _buildLimitedPlaceholder(
        context,
        constraints,
        limitConfig,
        colorScheme,
      ),
    };
  }

  Widget _buildLimitedPlaceholder(
    BuildContext context,
    PostDetailsSheetConstraints? constraints,
    LimitedPreview limitConfig,
    ColorScheme colorScheme,
  ) {
    final crossAxisCount = calculateGridCount(
      constraints?.maxWidth,
      GridSize.small,
    );
    final state = limitConfig.calculateState(
      totalCount: itemCount,
      crossAxisCount: crossAxisCount,
      isExpanded: false,
    );

    return SliverGrid.builder(
      itemCount: state.displayCount,
      addRepaintBoundaries: false,
      addSemanticIndexes: false,
      addAutomaticKeepAlives: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}

SliverGridDelegate _getGridDelegate(double? width) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: calculateGridCount(
      width,
      GridSize.small,
    ),
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
  );
}
