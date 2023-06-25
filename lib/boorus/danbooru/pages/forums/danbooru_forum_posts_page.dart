// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/dtext/html_converter.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/pages/forums/forum_post_header.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class DanbooruForumPostsPage extends ConsumerWidget {
  const DanbooruForumPostsPage({
    super.key,
    required this.topicId,
    required this.originalPostId,
  });

  final int topicId;
  final int originalPostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Posts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RiverPagedBuilder.autoDispose(
        firstPageProgressIndicatorBuilder: (context, controller) =>
            const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        pullToRefresh: false,
        firstPageKey: originalPostId,
        provider: danbooruForumPostsProvider(topicId),
        itemBuilder: (context, post, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ForumPostHeader(
                authorName: post.creator.name,
                createdAt: post.createdAt,
                authorLevel: post.creator.level,
                onTap: () =>
                    goToUserDetailsPage(ref, context, uid: post.creator.id),
              ),
              Html(
                onLinkTap: (url, context, attributes, element) =>
                    url != null ? launchExternalUrlString(url) : null,
                style: {
                  'body': Style(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  ),
                  'blockquote': Style(
                    padding: const EdgeInsets.only(left: 8),
                    margin: const EdgeInsets.only(left: 4, bottom: 16),
                    border: const Border(
                        left: BorderSide(color: Colors.grey, width: 3)),
                  )
                },
                data: dtext(post.body, booru: booru),
              ),
            ],
          ),
        ),
        pagedBuilder: (controller, builder) => PagedListView(
          pagingController: controller,
          builderDelegate: builder,
        ),
      ),
    );
  }
}
