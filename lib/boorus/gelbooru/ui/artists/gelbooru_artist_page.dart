// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/tags.dart';
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
      fetcher: (page) => context.read<PostRepository>().getPostsFromTags(
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
