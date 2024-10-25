// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'artist_tag_cloud.dart';

class DanbooruTagDetailsPage extends ConsumerStatefulWidget {
  const DanbooruTagDetailsPage({
    super.key,
    required this.tagName,
    required this.otherNames,
    this.extras,
  });

  final String tagName;
  final Widget otherNames;
  final List<Widget>? extras;

  @override
  ConsumerState<DanbooruTagDetailsPage> createState() =>
      _DanbooruTagDetailsPageState();
}

class _DanbooruTagDetailsPageState
    extends ConsumerState<DanbooruTagDetailsPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return PostScope(
      fetcher: (page) => postRepo.getPosts(
        queryFromTagFilterCategory(
          category: selectedCategory.value,
          tag: widget.tagName,
          builder: tagFilterCategoryToString,
        ),
        page,
      ),
      builder: (context, controller, error) => TagDetailsPageScaffold(
        tagName: widget.tagName,
        otherNames: widget.otherNames,
        extras: [
          if (widget.extras != null) ...widget.extras!,
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 16,
            ),
            child: ArtistTagCloud(
              tagName: widget.tagName,
            ),
          ),
        ],
        gridBuilder: (context, slivers) => DanbooruInfinitePostList(
          errors: error,
          controller: controller,
          sliverHeaders: slivers,
        ),
        onCategoryToggle: (category) {
          selectedCategory.value = category;
          controller.refresh();
        },
      ),
    );
  }
}
