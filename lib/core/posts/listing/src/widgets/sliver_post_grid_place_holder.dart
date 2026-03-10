// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_masonry_grid/sliver_masonry_grid.dart';

// Project imports:
import '../../../../images/booru_image.dart';
import '../../../../images/utils.dart';
import '../../../../settings/providers.dart';
import '../_internal/raw_post_grid.dart';
import '../types/image_list_type.dart';
import 'detailed_post_card.dart';

class SliverPostGridPlaceHolder extends ConsumerWidget {
  const SliverPostGridPlaceHolder({
    super.key,
    this.padding,
    this.listType,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
    this.postsPerPage,
  });

  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final int? postsPerPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = listType ?? ImageListType.standard;
    final imageGridSpacing = spacing ?? 4;
    final imageBorderRadius = borderRadius ?? BorderRadius.zero;
    final imageGridAspectRatio = aspectRatio ?? 1;
    final perPage = postsPerPage ?? 20;
    final constraints = PostGridConstraints.of(context);

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      sliver: Builder(
        builder: (context) {
          final crossAxisCount = constraints?.crossAxisCount ?? 3;

          return switch (imageListType) {
            ImageListType.masonry => SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: imageGridSpacing,
              crossAxisSpacing: imageGridSpacing,
              childCount: perPage,
              addRepaintBoundaries: false,
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              itemBuilder: (context, index) {
                return createRandomPlaceholderContainer(
                  context,
                  borderRadius: imageBorderRadius,
                );
              },
            ),
            ImageListType.detailed => _DetailedPlaceholder(
              spacing: imageGridSpacing,
              perPage: perPage,
            ),
            _ => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: imageGridAspectRatio,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: imageGridSpacing,
                crossAxisSpacing: imageGridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _) => ImagePlaceHolder(
                  borderRadius: imageBorderRadius,
                ),
                childCount: perPage,
                addRepaintBoundaries: false,
                addAutomaticKeepAlives: false,
                addSemanticIndexes: false,
              ),
            ),
          };
        },
      ),
    );
  }
}

class _DetailedPlaceholder extends ConsumerWidget {
  const _DetailedPlaceholder({
    required this.spacing,
    required this.perPage,
  });

  final double spacing;
  final int perPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.watch(
      imageListingSettingsProvider.select((v) => v.gridSize),
    );
    final cardHeight = detailedCardHeight(gridSize);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: ImagePlaceHolder(
            height: cardHeight,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        childCount: perPage,
        addRepaintBoundaries: false,
        addAutomaticKeepAlives: false,
        addSemanticIndexes: false,
      ),
    );
  }
}
