// Flutter imports:
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/comments/widgets.dart';
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/dtext/dtext.dart';
import '../../../../users/user/providers.dart';
import '../../../comment/types.dart';
import '../../../votes/providers.dart';
import '../../../votes/types.dart';

class CommentItem extends ConsumerWidget {
  const CommentItem({
    required this.comment,
    required this.onReply,
    required this.onVoteChanged,
    required this.hasVoteSection,
    super.key,
    this.moreBuilder,
  });
  final CommentData comment;
  final VoidCallback? onReply;
  final bool hasVoteSection;
  final void Function(VoteEvent event, DanbooruCommentVote? commentVote)
  onVoteChanged;
  final Widget Function(BuildContext context)? moreBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentVote = ref.watch(danbooruCommentVoteProvider(comment.id));
    final config = ref.watchConfigAuth;

    return CommentThreadItem(
      authorName: comment.authorName,
      authorTitleColor: DanbooruUserColor.of(
        context,
      ).fromLevel(comment.authorLevel),
      createdAt: comment.createdAt,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DTextBody(
            data: comment.body,
            booruUrl: config.url,
          ),
          ...comment.uris
              .where((e) => e.host == youtubeUrl)
              .map((e) => YoutubePreviewBox(uri: e)),
        ],
      ),
      isEdited: comment.isEdited,
      updatedAt: comment.updatedAt,
      score: comment.score + (commentVote?.score ?? 0),
      voteState: commentVote?.voteState ?? CommentVoteState.unvote,
      onVote: hasVoteSection
          ? (event) => onVoteChanged(event, commentVote)
          : null,
      onReply: hasVoteSection ? onReply : null,
      moreBuilder: hasVoteSection ? moreBuilder : null,
    );
  }
}
