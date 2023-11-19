// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/widgets/tags/post_tag_list.dart';
import 'widgets/moebooru_comment_section.dart';
import 'widgets/moebooru_information_section.dart';
import 'widgets/moebooru_related_post_section.dart';

class MoebooruPostDetailsPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.onExit,
  });

  final List<Post> posts;
  final int initialPage;
  final void Function(int page) onExit;

  @override
  ConsumerState<MoebooruPostDetailsPage> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPage> {
  List<Post> get posts => widget.posts;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(tagsProvider(ref.readConfig).notifier)
          .load(posts[widget.initialPage].tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialPage,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(
        context,
        tag: tag,
      ),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      sliverRelatedPostsBuilder: (context, post) =>
          MoebooruRelatedPostsSection(post: post),
      tagListBuilder: (context, post) => PostTagList(
        tags: ref.watch(tagsProvider(booruConfig)),
        onTap: (tag) => goToSearchPage(
          context,
          tag: tag.rawName,
        ),
      ),
      commentsBuilder: (context, post) => MoebooruCommentSection(post: post),
      infoBuilder: (context, post) => MoebooruInformationSection(post: post),
      onPageChanged: (post) {
        ref.read(tagsProvider(booruConfig).notifier).load(post.tags);
      },
    );
  }
}
