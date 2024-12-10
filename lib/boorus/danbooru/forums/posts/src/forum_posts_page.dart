// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/dtext/dtext.dart';
import '../../../../../core/forums/forum_post.dart';
import '../../../../../core/theme.dart';
import '../../../../../foundation/html.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../users/creator/providers.dart';
import '../../../users/details/routes.dart';
import '../../../users/user/user.dart';
import '../../topics/topic.dart';
import 'data/providers.dart';
import 'types/forum_post.dart';
import 'types/utils.dart';
import 'widgets/forum_post_header.dart';
import 'widgets/forum_post_vote_chips.dart';

class DanbooruForumPostsPage extends ConsumerStatefulWidget {
  const DanbooruForumPostsPage({
    super.key,
    required this.topic,
  });

  final DanbooruForumTopic topic;

  @override
  ConsumerState<DanbooruForumPostsPage> createState() =>
      _DanbooruForumPostsPageState();
}

class _DanbooruForumPostsPageState
    extends ConsumerState<DanbooruForumPostsPage> {
  late final pagingController = PagingController<int, DanbooruForumPost>(
    firstPageKey: DanbooruForumUtils.getFirstPageKey(
      responseCount: widget.topic.responseCount,
    ),
  );

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (pageKey <= 0) {
      pagingController.appendLastPage([]);
      return;
    }

    final posts = await ref
        .read(danbooruForumPostRepoProvider(ref.readConfigAuth))
        .getForumPostsOrEmpty(
          widget.topic.id,
          page: pageKey,
          limit: DanbooruForumUtils.postPerPage,
        );

    if (!mounted) return;

    pagingController.appendPage(posts, pageKey - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: PagedListView(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<DanbooruForumPost>(
            itemBuilder: (context, post, index) => _buildPost(post),
            firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
            newPageProgressIndicatorBuilder: (context) => _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Widget _buildPost(DanbooruForumPost post) {
    final config = ref.watchConfigAuth;
    final creator = ref.watch(danbooruCreatorProvider(post.creatorId));
    final creatorName = creator?.name ?? '...';
    final creatorLevel = creator?.level ?? UserLevel.member;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ForumPostHeader(
            authorName: creatorName,
            createdAt: post.createdAt,
            authorLevel: creatorLevel,
            onTap: () => goToUserDetailsPage(
              context,
              uid: post.creatorId,
            ),
          ),
          AppHtml(
            onLinkTap: !config.hasStrictSFW
                ? (url, attributes, element) =>
                    url != null ? launchExternalUrlString(url) : null
                : null,
            style: {
              'body': Style(
                margin: Margins.symmetric(vertical: 4),
              ),
              'blockquote': Style(
                padding: HtmlPaddings.only(left: 8),
                margin: Margins.only(
                  left: 4,
                  bottom: 12,
                  top: 8,
                ),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.hintColor,
                    width: 3,
                  ),
                ),
              ),
            },
            data: dtext(post.body, booruUrl: config.url),
          ),
          if (post.votes.isNotEmpty) ...[
            const SizedBox(height: 8),
            DanbooruForumVoteChips(
              votes: post.votes,
            ),
          ],
        ],
      ),
    );
  }
}
