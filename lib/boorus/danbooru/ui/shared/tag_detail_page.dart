// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts/danbooru_infinite_post_list2.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/tags.dart';

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
    this.includeHeaders = true,
  });

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final bool includeHeaders;

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage>
    with DanbooruArtistCharacterPostCubitMixin {
  late final controller = PostGridController<DanbooruPost>(
      fetcher: fetchPost, refresher: refreshPost);

  @override
  Widget build(BuildContext context) {
    return DanbooruInfinitePostList2(
      controller: controller,
      onLoadMore: () => {},
      // onRefresh: () => refresh(context),
      sliverHeaderBuilder: (context) => [
        if (widget.includeHeaders)
          SliverAppBar(
            floating: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              IconButton(
                onPressed: () {
                  goToBulkDownloadPage(
                    context,
                    [widget.tagName],
                  );
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ),
        if (widget.includeHeaders)
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TagTitleName(tagName: widget.tagName),
                widget.otherNamesBuilder(context),
              ],
            ),
          ),
        if (widget.includeHeaders)
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 10),
          sliver: SliverToBoxAdapter(
            child: CategoryToggleSwitch(
              onToggle: (category) => changeCategory(category),
            ),
          ),
        ),
      ],
    );
  }
}
