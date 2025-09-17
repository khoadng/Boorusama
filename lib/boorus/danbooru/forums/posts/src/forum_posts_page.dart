// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/dtext/dtext.dart';
import '../../../../../core/forums/forum_post.dart';
import '../../../../../core/theme.dart';
import '../../../../../foundation/html.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
import '../../../users/creator/providers.dart';
import '../../../users/details/routes.dart';
import '../../../users/details/types.dart';
import '../../../users/user/user.dart';
import '../../topics/topic.dart';
import 'data/providers.dart';
import 'types/forum_post.dart';
import 'types/utils.dart';
import 'widgets/forum_post_header.dart';
import 'widgets/forum_post_vote_chips.dart';

class DanbooruForumPostsPage extends ConsumerStatefulWidget {
  const DanbooruForumPostsPage({
    required this.topic,
    super.key,
  });

  final DanbooruForumTopic topic;

  @override
  ConsumerState<DanbooruForumPostsPage> createState() =>
      _DanbooruForumPostsPageState();
}

class _DanbooruForumPostsPageState
    extends ConsumerState<DanbooruForumPostsPage> {
  late var currentPage = DanbooruForumUtils.getFirstPageKey(
    responseCount: widget.topic.responseCount,
  );
  List<DanbooruForumPost> posts = [];
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPage(currentPage);
  }

  Future<void> _fetchPage(int page) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final newPosts = await ref
        .read(danbooruForumPostRepoProvider(ref.readConfigAuth))
        .getForumPostsOrEmpty(
          widget.topic.id,
          page: page,
          limit: DanbooruForumUtils.postPerPage,
        );

    if (!mounted) return;

    setState(() {
      posts = newPosts;
      isLoading = false;
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = calculateTotalPage(
      widget.topic.responseCount,
      DanbooruForumUtils.postPerPage,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
      ),
      body: Column(
        children: [
          if (totalPages != null && totalPages > 1)
            PageSelector(
              currentPage: totalPages - currentPage + 1,
              totalResults: widget.topic.responseCount,
              itemPerPage: DanbooruForumUtils.postPerPage,
              onPageSelect: (page) => _fetchPage(totalPages - page + 1),
              onNext: () => _fetchPage(currentPage - 1),
              onPrevious: () => _fetchPage(currentPage + 1),
              showLastPage: true,
            ),
          Expanded(
            child: isLoading
                ? _buildLoading()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _buildPost(posts[index]),
                  ),
          ),
        ],
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
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final creator = ref.watch(
                danbooruCreatorProvider(post.creatorId),
              );

              final creatorName = creator?.name ?? '...';
              final creatorLevel = creator?.level ?? UserLevel.member;

              return ForumPostHeader(
                authorName: creatorName,
                createdAt: post.createdAt,
                authorLevel: creatorLevel,
                onTap: creator != null
                    ? () => goToUserDetailsPage(
                        ref,
                        details: UserDetails.fromCreator(creator),
                      )
                    : null,
              );
            },
          ),
          AppHtml(
            onLinkTap: !loginDetails.hasStrictSFW
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
