// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/functional.dart';

class GelbooruArtistPage extends StatefulWidget {
  const GelbooruArtistPage({
    super.key,
    required this.tagName,
    this.includeHeaders = true,
  });

  final String tagName;
  final bool includeHeaders;

  @override
  State<GelbooruArtistPage> createState() => _GelbooruArtistPageState();
}

class _GelbooruArtistPageState extends State<GelbooruArtistPage> {
  late final controller = PostGridController<Post>(
    fetcher: (page) => context
        .read<PostRepository>()
        .getPostsFromTags(
          queryFromTagFilterCategory(
            category: selectedCategory.value,
            tag: widget.tagName,
            builder: (category) => category == TagFilterCategory.popular
                ? some('sort:score:desc')
                : none(),
          ),
          page,
        )
        .run()
        .then((value) => value.fold(
              (l) => <Post>[],
              (r) => r,
            )),
    refresher: () => context
        .read<PostRepository>()
        .getPostsFromTags(
          queryFromTagFilterCategory(
            category: selectedCategory.value,
            tag: widget.tagName,
            builder: (category) => category == TagFilterCategory.popular
                ? some('sort:score:desc')
                : none(),
          ),
          1,
        )
        .run()
        .then((value) => value.fold(
              (l) => <Post>[],
              (r) => r,
            )),
  );

  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GelbooruInfinitePostList(
      controller: controller,
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
              ],
            ),
          ),
        if (widget.includeHeaders)
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 10),
          sliver: SliverToBoxAdapter(
            child: CategoryToggleSwitch(
              onToggle: (category) {
                selectedCategory.value = category;
                controller.refresh();
              },
            ),
          ),
        ),
      ],
    );
  }
}
