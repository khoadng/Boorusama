// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/dtext/dtext.dart';
import 'package:boorusama/core/forums/forums.dart';
import 'package:boorusama/core/users/users.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/string.dart';

class DanbooruForumPostsPage extends ConsumerStatefulWidget {
  const DanbooruForumPostsPage({
    super.key,
    required this.topicId,
    required this.title,
    required this.responseCount,
  });

  final int topicId;
  final int responseCount;
  final String title;

  @override
  ConsumerState<DanbooruForumPostsPage> createState() =>
      _DanbooruForumPostsPageState();
}

class _DanbooruForumPostsPageState
    extends ConsumerState<DanbooruForumPostsPage> {
  final int _pageSize = 20;
  late final pagingController = PagingController<int, DanbooruForumPost>(
    firstPageKey: (widget.responseCount / _pageSize).ceil(),
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
        .read(danbooruForumPostRepoProvider(ref.readConfig))
        .getForumPostsOrEmpty(
          widget.topicId,
          page: pageKey,
          limit: _pageSize,
        );

    if (!mounted) return;

    pagingController.appendPage(posts, pageKey - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
    final config = ref.watchConfig;
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
              ref,
              context,
              uid: post.creatorId,
              username: creatorName,
            ),
          ),
          Html(
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
                margin: Margins.only(left: 4, bottom: 16),
                border: const Border(
                    left: BorderSide(color: Colors.grey, width: 3)),
              )
            },
            data: dtext(post.body, booruUrl: config.url),
          ),
          const SizedBox(height: 8),
          if (post.votes.isNotEmpty)
            _VoteChips(
              votes: post.votes,
            )
        ],
      ),
    );
  }
}

class _VoteChips extends ConsumerWidget {
  const _VoteChips({
    required this.votes,
  });

  final List<DanbooruForumPostVote> votes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: votes.map((e) {
        final creator = ref.watch(danbooruCreatorProvider(e.creatorId));

        return ForumVoteChip(
          icon: switch (e.type) {
            DanbooruForumPostVoteType.upvote => Icon(
                Symbols.arrow_upward,
                color: _iconColor(e.type),
              ),
            DanbooruForumPostVoteType.downvote => Icon(
                Symbols.arrow_downward,
                color: _iconColor(e.type),
              ),
            DanbooruForumPostVoteType.unsure => Container(
                margin: const EdgeInsets.all(4),
                child: FaIcon(
                  FontAwesomeIcons.faceMeh,
                  size: 16,
                  color: _iconColor(e.type),
                ),
              ),
          },
          color: _color(e.type),
          borderColor: _borderColor(e.type),
          label: Text(
            creator?.name.replaceUnderscoreWithSpace() ?? 'User',
            style: TextStyle(
              color: creator?.level.toColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

Color _color(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff01370a),
      DanbooruForumPostVoteType.downvote => const Color(0xff5c1212),
      DanbooruForumPostVoteType.unsure => const Color(0xff382c00),
    };

Color _borderColor(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff016f19),
      DanbooruForumPostVoteType.downvote => const Color(0xffc10105),
      DanbooruForumPostVoteType.unsure => const Color(0xff675403),
    };

Color _iconColor(DanbooruForumPostVoteType type) => switch (type) {
      DanbooruForumPostVoteType.upvote => const Color(0xff01aa2d),
      DanbooruForumPostVoteType.downvote => const Color(0xffff5b5a),
      DanbooruForumPostVoteType.unsure => const Color(0xffdac278),
    };
