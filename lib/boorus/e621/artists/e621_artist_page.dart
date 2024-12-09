// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/tags/details/widgets/tag_details_page_scaffold.dart';
import 'package:boorusama/core/tags/details/widgets/tag_other_names.dart';
import 'package:boorusama/core/tags/tag/filter_category.dart';

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
    final config = ref.watchConfigSearch;

    return PostScope(
      fetcher: (page) => ref.read(e621PostRepoProvider(config)).getPosts(
            queryFromTagFilterCategory(
              category: selectedCategory.value,
              tag: widget.artistName,
              builder: tagFilterCategoryToString,
            ),
            page,
          ),
      builder: (context, controller) => TagDetailsPageScaffold(
        onCategoryToggle: (category) {
          selectedCategory.value = category;
          controller.refresh();
        },
        tagName: widget.artistName,
        otherNames: artist.when(
          data: (data) => TagOtherNames(otherNames: data.otherNames),
          error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
          loading: () => const TagOtherNames(otherNames: null),
        ),
        gridBuilder: (context, slivers) => PostGrid(
          controller: controller,
          sliverHeaders: slivers,
        ),
      ),
    );
  }
}

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
