// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/scaffolds/tag_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

class GelbooruArtistPage extends ConsumerStatefulWidget {
  const GelbooruArtistPage({
    super.key,
    required this.artistName,
  });

  final String artistName;

  @override
  ConsumerState<GelbooruArtistPage> createState() => _GelbooruArtistPageState();
}

class _GelbooruArtistPageState extends ConsumerState<GelbooruArtistPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) =>
          ref.read(gelbooruArtistCharacterPostRepoProvider).getPostsFromTags(
                queryFromTagFilterCategory(
                  category: selectedCategory.value,
                  tag: widget.artistName,
                  builder: (category) => category == TagFilterCategory.popular
                      ? some('sort:score:desc')
                      : none(),
                ),
                page,
              ),
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
