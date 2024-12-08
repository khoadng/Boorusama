// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/comments/vote_event.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'comment_vote.dart';

class CommentVoteSection extends StatelessWidget {
  const CommentVoteSection({
    super.key,
    required this.onReply,
    required this.moreBuilder,
    this.onVote,
    required this.score,
    required this.voteState,
  });

  final VoidCallback? onReply;
  final Widget Function(BuildContext context)? moreBuilder;
  final void Function(VoteEvent event)? onVote;
  final CommentVoteState voteState;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoteButton(
          onTap: () {
            VoteEvent event;
            if (voteState == CommentVoteState.downvoted) {
              event = VoteEvent.upvoted;
            } else if (voteState == CommentVoteState.unvote) {
              event = VoteEvent.upvoted;
            } else {
              event = VoteEvent.voteRemoved;
            }
            onVote?.call(event);
          },
          icon: Icon(
            Symbols.arrow_upward_alt,
            color: voteState == CommentVoteState.upvoted
                ? context.colors.upvoteColor
                : context.iconTheme.color,
            size: 24,
          ),
        ),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 14),
        ),
        _VoteButton(
          onTap: () {
            VoteEvent event;
            if (voteState == CommentVoteState.upvoted) {
              event = VoteEvent.downvote;
            } else if (voteState == CommentVoteState.unvote) {
              event = VoteEvent.downvote;
            } else {
              event = VoteEvent.voteRemoved;
            }
            onVote?.call(event);
          },
          icon: Icon(
            Symbols.arrow_downward_alt,
            color: voteState == CommentVoteState.downvoted
                ? context.colors.downvoteColor
                : context.iconTheme.color,
            size: 24,
          ),
        ),
        if (onReply != null)
          TextButton(
            onPressed: onReply,
            child: const Text('comment.list.reply').tr(),
          ),
        if (moreBuilder != null) moreBuilder!(context),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: IconButton(
        iconSize: 16,
        splashRadius: 16,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: icon,
      ),
    );
  }
}
