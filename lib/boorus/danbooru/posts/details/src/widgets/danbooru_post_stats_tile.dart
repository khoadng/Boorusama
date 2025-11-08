// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/router.dart';
import '../../../../users/user/routes.dart';
import '../../../post/types.dart';

class DanbooruPostStatsTile extends ConsumerWidget {
  const DanbooruPostStatsTile({
    required this.post,
    required this.commentCount,
    super.key,
  });

  final DanbooruPost post;
  final int? commentCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimplePostStatsTile(
      score: post.score,
      favCount: post.favCount,
      totalComments: commentCount ?? 0,
      votePercentText: _generatePercentText(post),
      onScoreTap: () => goToPostVotesDetails(ref, post),
      onFavCountTap: () => goToPostFavoritesDetails(ref, post),
      onTotalCommentsTap: () => goToCommentPage(context, ref, post),
    );
  }

  String _generatePercentText(DanbooruPost post) {
    return post.totalVote > 0
        ? '(${(post.upvotePercent * 100).toInt()}% upvoted)'
        : '';
  }
}
