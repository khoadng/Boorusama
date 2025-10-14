// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/tags/details/widgets.dart';
import '../../../core/tags/tag/types.dart';
import '../posts/providers.dart';
import 'providers.dart';

class E621ArtistPage extends ConsumerStatefulWidget {
  const E621ArtistPage({
    required this.artistName,
    super.key,
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
      fetcher: (page) => ref
          .read(e621PostRepoProvider(config))
          .getPosts(
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
