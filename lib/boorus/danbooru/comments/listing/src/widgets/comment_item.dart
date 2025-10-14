// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/comments/widgets.dart';
import '../../../../../../core/dtext/dtext.dart';
import '../../../../../../core/themes/theme/types.dart';
import '../../../../dtext/types.dart';
import '../../../comment/types.dart';
import '../../../votes/providers.dart';
import '../../../votes/types.dart';
import 'danbooru_comment_header.dart';

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
          if (comment.updatedAt case final DateTime updatedAt)
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
