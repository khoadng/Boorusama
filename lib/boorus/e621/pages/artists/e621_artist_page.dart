// Flutter imports:
import 'package:boorusama/functional.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/scaffolds/tag_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

class E621ArtistPage extends ConsumerStatefulWidget {
  const E621ArtistPage({
    super.key,
    required this.artistName,
  });

  final String artistName;

  @override
  ConsumerState<E621ArtistPage> createState() => _E621ArtistPageState();
}

class _E621ArtistPageState extends ConsumerState<E621ArtistPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    final artist = ref.watch(e621ArtistProvider(widget.artistName));

    return PostScope(
      fetcher: (page) => ref.read(e621PostRepoProvider).getPosts(
            queryFromTagFilterCategory(
              category: selectedCategory.value,
              tag: widget.artistName,
              builder: tagFilterCategoryToString,
            ),
            page,
          ),
      builder: (context, controller, errors) => TagDetailsPageScaffold(
        onCategoryToggle: (category) {
          selectedCategory.value = category;
          controller.refresh();
        },
        tagName: widget.artistName,
        otherNamesBuilder: (_) => artist.when(
          data: (data) => TagOtherNames(otherNames: data.otherNames),
          error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
          loading: () => const TagOtherNames(otherNames: null),
        ),
        gridBuilder: (context, slivers) => InfinitePostListScaffold(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) => slivers,
          onPostTap: (context, posts, post, scrollController, settings,
                  initialIndex) =>
              goToPostDetailsPage(
            context: context,
            posts: posts,
            initialIndex: initialIndex,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
