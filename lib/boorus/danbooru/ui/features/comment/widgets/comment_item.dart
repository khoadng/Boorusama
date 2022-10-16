// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/comment/dtext_parser.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/widgets/dtext.dart';
import 'package:boorusama/core/core.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.comment,
    required this.onReply,
    required this.onVoteChanged,
    required this.hasVoteSection,
    this.moreBuilder,
  }) : super(key: key);
  final CommentData comment;
  final VoidCallback onReply;
  final bool hasVoteSection;
  final void Function(VoteEvent event) onVoteChanged;
  final Widget Function(BuildContext context)? moreBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentHeader(
          authorName: comment.authorName,
          authorLevel: comment.authorLevel,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        Dtext.parse(
          parseDtext(comment.body),
          '[quote]',
          '[/quote]',
        ),
        if (comment.recentlyUpdated)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${'comment.list.last_updated'.tr()}: ${dateTimeToStringTimeAgo(
                comment.updatedAt,
                locale: Localizations.localeOf(context).languageCode,
              )}',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        if (!hasVoteSection) const SizedBox(height: 8),
        if (hasVoteSection)
          _VoteSection(
            score: comment.score,
            voteState: comment.voteState,
            onVote: onVoteChanged,
            onReply: onReply,
            moreBuilder: moreBuilder,
          )
      ],
    );
  }
}

class SimpleCommentItem extends StatelessWidget {
  const SimpleCommentItem({
    Key? key,
    required this.authorName,
    required this.content,
    required this.createdAt,
  }) : super(key: key);
  final String authorName;
  final String content;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentHeader(
          authorName: authorName,
          createdAt: createdAt,
        ),
        Dtext.parse(
          content,
          '[quote]',
          '[/quote]',
        ),
      ],
    );
  }
}

enum VoteEvent {
  upvoted,
  downvote,
  voteRemoved,
}

class _VoteSection extends StatelessWidget {
  const _VoteSection({
    Key? key,
    required this.onReply,
    required this.moreBuilder,
    this.onVote,
    required this.score,
    required this.voteState,
  }) : super(key: key);

  final VoidCallback onReply;
  final Widget Function(BuildContext context)? moreBuilder;
  final void Function(VoteEvent event)? onVote;
  final CommentVoteState voteState;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
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
            icon: FaIcon(
              FontAwesomeIcons.arrowDown,
              color: voteState == CommentVoteState.downvoted
                  ? Colors.redAccent
                  : Theme.of(context).iconTheme.color,
            ),
          ),
          TextButton(
            onPressed: onReply,
            child: const Text('comment.list.reply').tr(),
          ),
          if (moreBuilder != null) moreBuilder!(context),
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
    required this.authorName,
    this.authorLevel,
    required this.createdAt,
  }) : super(key: key);

  final String authorName;
  final UserLevel? authorLevel;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        Text(
          authorName.replaceAll('_', ' '),
          style: TextStyle(
            color: authorLevel != null ? Color(authorLevel!.hexColor) : null,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          DateFormat('MMM d, yyyy hh:mm a').format(createdAt.toLocal()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
