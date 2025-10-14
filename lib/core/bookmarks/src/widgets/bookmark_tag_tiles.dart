// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../posts/details/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../data/bookmark_convert.dart';
import '../providers/local_providers.dart';

class BookmarkTagTiles extends ConsumerStatefulWidget {
  const BookmarkTagTiles({super.key});

  @override
  ConsumerState<BookmarkTagTiles> createState() => _BookmarkTagTilesState();
}

class _BookmarkTagTilesState extends ConsumerState<BookmarkTagTiles> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<BookmarkPost>(context);
    final originalPost = post.toOriginalPost();
    final config = ref.watch(
      firstMatchingConfigProvider((
        post.bookmark.booruId,
        post.bookmark.sourceUrl,
      )),
    );

    if (config == null) {
      return const DefaultInheritedBasicTagsTile<BookmarkPost>();
    }

    final params = (config.auth, post);

    if (expanded) {
      ref.listen(
        bookmarkTagGroupsProvider(params),
        (previous, next) {
          next.when(
            data: (data) {
              if (!mounted) return;

              if (data == null || (data.isEmpty && post.tags.isNotEmpty)) {
                // Just a dummy data so the check below will branch into the else block
                setState(() => error = 'No tags found');
              }
            },
            loading: () {},
            error: (error, stackTrace) {
              if (!mounted) return;
              setState(() => this.error = error);
            },
          );
        },
      );
    }

    return SliverToBoxAdapter(
      child: error == null
          ? TagsTile(
              auth: config.auth,
              tags: expanded
                  ? ref.watch(bookmarkTagGroupsProvider(params)).valueOrNull
                  : null,
              post: originalPost,
              onExpand: () => setState(() => expanded = true),
              onCollapse: () {
                // Don't set expanded to false to prevent rebuilding the tags list
                setState(() => error = null);
              },
            )
          : BasicTagsTile(
              post: post,
              tags: post.tags,
              auth: config.auth,
            ),
    );
  }
}
