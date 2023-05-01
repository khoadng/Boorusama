// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts/post_utils.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_artist_character_post_repository.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/tags.dart';
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

class _TagDetailPageState extends State<TagDetailPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return DanbooruPostScope(
      fetcher: (page) =>
          context.read<DanbooruArtistCharacterPostRepository>().getPosts(
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
