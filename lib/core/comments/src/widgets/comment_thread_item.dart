// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import '../types/comment_vote.dart';
import '../types/vote_event.dart';
import 'comment_header.dart';
import 'comment_vote_section.dart';

class CommentThreadItem extends StatelessWidget {
  const CommentThreadItem({
    required this.authorName,
    required this.createdAt,
    required this.body,
    required this.score,
    required this.voteState,
    super.key,
    this.authorTitleColor,
    this.isEdited = false,
    this.updatedAt,
    this.onVote,
    this.onReply,
    this.moreBuilder,
  });

  final String authorName;
  final DateTime? createdAt;
  final Color? authorTitleColor;
  final Widget body;
  final bool isEdited;
  final DateTime? updatedAt;
  final int score;
  final CommentVoteState voteState;
  final void Function(VoteEvent event)? onVote;
  final VoidCallback? onReply;
  final Widget Function(BuildContext context)? moreBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: authorName,
          authorTitleColor:
              authorTitleColor ?? Theme.of(context).colorScheme.primary,
          createdAt: createdAt,
        ),
        const SizedBox(height: 4),
        body,
        if (isEdited)
          if (updatedAt case final DateTime updatedAt)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${context.t.comment.list.last_updated}: ${updatedAt.fuzzify(locale: Localizations.localeOf(context))}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.hintColor,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
        CommentVoteSection(
          score: score,
          voteState: voteState,
          onVote: onVote,
          onReply: onReply,
          moreBuilder: moreBuilder,
        ),
      ],
    );
  }
}
