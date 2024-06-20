// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/functional.dart';

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
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => ref.read(e621PostRepoProvider(config)).getPosts(
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
        ),
      ),
    );
  }
}

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
