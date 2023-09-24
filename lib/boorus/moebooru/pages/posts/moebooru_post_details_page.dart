// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/tags/post_tag_list.dart';
import 'package:boorusama/boorus/moebooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/moebooru/pages/comments/moebooru_comment_item.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'moebooru_information_section.dart';
import 'moebooru_related_post_section.dart';

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
    ref
        .read(tagsProvider(ref.read(currentBooruConfigProvider)).notifier)
        .load(posts[widget.initialPage].tags);
  }

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final settings = ref.watch(settingsProvider);

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialPage,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(
        context,
        tag: tag,
      ),
      toolbarBuilder: (context, post) => MoebooruPostActionToolbar(post: post),
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
      swipeImageUrlBuilder: (post) => post.thumbnailFromSettings(settings),
      onPageChanged: (post) {
        ref.read(tagsProvider(booruConfig).notifier).load(post.tags);
      },
    );
  }
}

class MoebooruCommentSection extends ConsumerWidget {
  const MoebooruCommentSection({
    super.key,
    required this.post,
    this.allowFetch = true,
  });

  final Post post;
  final bool allowFetch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!allowFetch) {
      return const SizedBox.shrink();
    }

    final asyncData = ref.watch(moebooruCommentsProvider(post.id));

    return asyncData.when(
      data: (comments) => comments.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    thickness: 1.5,
                  ),
                  Text(
                    'comment.comments'.tr(),
                    style: context.textTheme.titleLarge!.copyWith(
                      color: context.theme.hintColor,
                      fontSize: 16,
                    ),
                  ),
                  ...comments
                      .map((comment) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MoebooruCommentItem(comment: comment),
                          ))
                      .toList()
                ],
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (e, __) => const SizedBox.shrink(),
    );
  }
}
