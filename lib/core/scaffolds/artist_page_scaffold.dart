// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/scaffolds/tag_details_page_scaffold.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class ArtistPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const ArtistPageScaffold({
    super.key,
    required this.artistName,
    required this.fetcher,
  });

  final String artistName;
  final PostsOrErrorCore<T> Function(
      int page, TagFilterCategory selectedCategory) fetcher;

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
      builder: (context, controller, errors) => TagDetailsPageScaffold(
        onCategoryToggle: (category) {
          selectedCategory.value = category;
          controller.refresh();
        },
        tagName: widget.artistName,
        otherNamesBuilder: (_) => const SizedBox(height: 40, width: 40),
        gridBuilder: (context, slivers) => InfinitePostListScaffold(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) => slivers,
        ),
      ),
    );
  }
}
