// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/core/pages/posts/post_scope.dart';
import 'package:boorusama/boorus/core/pages/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/gelbooru/feat/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/functional.dart';

class GelbooruArtistPage extends ConsumerStatefulWidget {
  const GelbooruArtistPage({
    super.key,
    required this.tagName,
    this.includeHeaders = true,
  });

  final String tagName;
  final bool includeHeaders;

  @override
  ConsumerState<GelbooruArtistPage> createState() => _GelbooruArtistPageState();
}

class _GelbooruArtistPageState extends ConsumerState<GelbooruArtistPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) =>
          ref.watch(gelbooruArtistCharacterPostRepoProvider).getPostsFromTags(
                queryFromTagFilterCategory(
                  category: selectedCategory.value,
                  tag: widget.tagName,
                  builder: (category) => category == TagFilterCategory.popular
                      ? some('sort:score:desc')
                      : none(),
                ),
                page,
              ),
      builder: (context, controller, errors) => GelbooruInfinitePostList(
        errors: errors,
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
                      ref: ref,
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
      ),
    );
  }
}
