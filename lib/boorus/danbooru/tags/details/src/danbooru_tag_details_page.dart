// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/tags/details/widgets.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/providers.dart';
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
    final config = ref.watchConfigSearch;
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
      builder: (context, controller) => TagDetailsPageScaffold(
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
        gridBuilder: (context, slivers) => PostGrid(
          controller: controller,
          itemBuilder:
              (context, index, multiSelectController, scrollController) =>
                  DefaultDanbooruImageGridItem(
            index: index,
            multiSelectController: multiSelectController,
            autoScrollController: scrollController,
            controller: controller,
          ),
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

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
