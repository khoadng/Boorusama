// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../posts/listing/widgets.dart';
import '../posts/post/post.dart';
import '../tags/details/widgets.dart';
import '../tags/tag/tag.dart';

class ArtistPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const ArtistPageScaffold({
    super.key,
    required this.artistName,
    required this.fetcher,
  });

  final String artistName;
  final PostsOrErrorCore<T> Function(
    int page,
    TagFilterCategory selectedCategory,
  ) fetcher;

  @override
  ConsumerState<ArtistPageScaffold<T>> createState() =>
      _ArtistPageScaffoldState<T>();
}

class _ArtistPageScaffoldState<T extends Post>
    extends ConsumerState<ArtistPageScaffold<T>> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) => widget.fetcher(page, selectedCategory.value),
      builder: (context, controller) => TagDetailsPageScaffold(
        onCategoryToggle: (category) {
          selectedCategory.value = category;
          controller.refresh();
        },
        tagName: widget.artistName,
        otherNames: const SizedBox(height: 40, width: 40),
        gridBuilder: (context, slivers) => PostGrid(
          controller: controller,
          sliverHeaders: slivers,
        ),
      ),
    );
  }
}
