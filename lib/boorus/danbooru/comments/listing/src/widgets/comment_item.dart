// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/comments/comment_vote.dart';
import 'package:boorusama/core/comments/comment_vote_section.dart';
import 'package:boorusama/core/comments/vote_event.dart';
import 'package:boorusama/core/comments/youtube_preview_box.dart';
import 'package:boorusama/core/dtext/dtext.dart';
import 'package:boorusama/core/theme.dart';
import '../../../../dtext/dtext.dart';
import '../../../comment/comment.dart';
import '../../../votes/providers.dart';
import '../../../votes/vote.dart';
import 'danbooru_comment_header.dart';

class CommentItem extends ConsumerWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onVoteChanged,
    required this.hasVoteSection,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DanbooruCommentHeader(comment: comment),
        const SizedBox(height: 4),
        Dtext.parse(
          parseDtext(comment.body),
          '[quote]',
          '[/quote]',
        ),
        ...comment.uris
            .where((e) => e.host == youtubeUrl)
            .map((e) => YoutubePreviewBox(uri: e)),
        if (comment.isEdited)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${'comment.list.last_updated'.tr()}: ${comment.updatedAt.fuzzify(locale: Localizations.localeOf(context))}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.hintColor,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        if (!hasVoteSection) const SizedBox(height: 8),
        if (hasVoteSection)
          CommentVoteSection(
            score: comment.score + (commentVote?.score ?? 0),
            voteState: commentVote?.voteState ?? CommentVoteState.unvote,
            onVote: (event) => onVoteChanged(event, commentVote),
            onReply: onReply,
            moreBuilder: moreBuilder,
          ),
      ],
    );
  }
}
