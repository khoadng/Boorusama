// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/dtext_parser.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/widgets/dtext.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/widgets/youtube_preview_box.dart';
import 'package:boorusama/core/core.dart';
import 'comment_header.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onVoteChanged,
    required this.hasVoteSection,
    this.moreBuilder,
  });
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
        CommentHeader(
          authorName: comment.authorName,
          authorLevel: comment.authorLevel,
          createdAt: comment.createdAt,
          onTap: () => goToUserDetailsPage(
            context,
            uid: comment.authorId,
          ),
        ),
        const SizedBox(height: 4),
        Dtext.parse(
          parseDtext(comment.body),
          '[quote]',
          '[/quote]',
        ),
        ...comment.uris
            .where((e) => e.host == youtubeUrl)
            .map((e) => YoutubePreviewBox(uri: e)),
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
    required this.onReply,
    required this.moreBuilder,
    this.onVote,
    required this.score,
    required this.voteState,
  });

  final VoidCallback onReply;
  final Widget Function(BuildContext context)? moreBuilder;
  final void Function(VoteEvent event)? onVote;
  final CommentVoteState voteState;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    required this.onTap,
    required this.icon,
  });

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
