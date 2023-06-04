// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'danbooru_infinite_post_list.dart';
import 'danbooru_post_scope.dart';

class TagDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends ConsumerState<TagDetailPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return DanbooruPostScope(
      fetcher: (page) =>
          ref.read(danbooruArtistCharacterPostRepoProvider).getPosts(
                queryFromTagFilterCategory(
                  category: selectedCategory.value,
                  tag: widget.tagName,
                  builder: tagFilterCategoryToString,
                ),
                page,
              ),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
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
                const PostGridConfigIconButton(),
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
