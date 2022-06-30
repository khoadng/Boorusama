// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/dtext.dart';
import 'package:boorusama/core/core.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.comment,
    required this.onReply,
    this.moreBuilder,
  }) : super(key: key);
  final CommentData comment;
  final VoidCallback onReply;
  final Widget Function(BuildContext context)? moreBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentHeader(comment: comment),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buidCommentBody(),
        ),
        if (comment.recentlyUpdated)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Last updated: ${dateTimeToStringTimeAgo(comment.updatedAt)}',
              style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                  fontSize: 12),
            ),
          ),
        _VoteSection(
          comment: comment,
          onReply: onReply,
          moreBuilder: moreBuilder,
        )
      ],
    );
  }

  Widget _buidCommentBody() {
    return Dtext.parse(
      comment.body,
      '[quote]',
      '[/quote]',
    );
  }
}

enum VoteEvent {
  upvoted,
  downvote,
  voteRemoved,
}

class _VoteSection extends StatefulWidget {
  const _VoteSection({
    Key? key,
    required this.comment,
    required this.onReply,
    required this.moreBuilder,
    this.onVote,
  }) : super(key: key);

  final CommentData comment;
  final VoidCallback onReply;
  final Widget Function(BuildContext context)? moreBuilder;
  final void Function(VoteEvent event)? onVote;

  @override
  State<_VoteSection> createState() => _VoteSectionState();
}

class _VoteSectionState extends State<_VoteSection> {
  late CommentVoteState voteState = widget.comment.voteState;
  late int score = widget.comment.score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoteButton(
            onTap: () {
              setState(() {
                VoteEvent event;
                if (voteState == CommentVoteState.downvoted) {
                  score += 2;
                  event = VoteEvent.upvoted;
                } else if (voteState == CommentVoteState.unvote) {
                  score += 1;
                  event = VoteEvent.upvoted;
                } else {
                  score -= 1;
                  event = VoteEvent.voteRemoved;
                }
                widget.onVote?.call(event);

                if (voteState == CommentVoteState.unvote) {
                  voteState = CommentVoteState.upvoted;
                } else if (voteState == CommentVoteState.upvoted) {
                  voteState = CommentVoteState.unvote;
                } else {
                  voteState = CommentVoteState.upvoted;
                }
              });
            },
            icon: FaIcon(
              FontAwesomeIcons.arrowUp,
              color: voteState == CommentVoteState.upvoted
                  ? Colors.redAccent
                  : Theme.of(context).iconTheme.color,
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(fontSize: 14),
          ),
          _VoteButton(
            onTap: () {
              setState(() {
                VoteEvent event;
                if (voteState == CommentVoteState.upvoted) {
                  score -= 2;

                  event = VoteEvent.downvote;
                } else if (voteState == CommentVoteState.unvote) {
                  score -= 1;

                  event = VoteEvent.downvote;
                } else {
                  score += 1;
                  event = VoteEvent.voteRemoved;
                }
                widget.onVote?.call(event);
                if (voteState == CommentVoteState.unvote) {
                  voteState = CommentVoteState.downvoted;
                } else if (voteState == CommentVoteState.downvoted) {
                  voteState = CommentVoteState.unvote;
                } else {
                  voteState = CommentVoteState.downvoted;
                }
              });
            },
            icon: FaIcon(
              FontAwesomeIcons.arrowDown,
              color: voteState == CommentVoteState.downvoted
                  ? Colors.redAccent
                  : Theme.of(context).iconTheme.color,
            ),
          ),
          TextButton(
            onPressed: widget.onReply,
            child: const Text('Reply'),
          ),
          if (widget.moreBuilder != null) widget.moreBuilder!(context),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    Key? key,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 30,
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

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          comment.authorName.replaceAll('_', ' '),
          style: TextStyle(
            color: Color(comment.authorLevel.hexColor),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          DateFormat('MMM d, yyyy hh:mm a').format(comment.createdAt.toLocal()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
