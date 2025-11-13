// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import '../../../widgets/booru_tooltip.dart';
import 'post_vote.dart';

class UpvotePostButton extends StatelessWidget {
  const UpvotePostButton({
    required this.voteState,
    required this.onUpvote,
    required this.onRemoveUpvote,
    super.key,
  });

  final VoteState voteState;
  final void Function() onUpvote;
  final void Function()? onRemoveUpvote;

  @override
  Widget build(BuildContext context) {
    return BooruTooltip(
      message: context.t.post.action.upvote,
      child: IconButton(
        icon: Icon(
          Symbols.arrow_upward,
          color: voteState.isUpvoted ? context.colors.upvoteColor : null,
        ),
        splashRadius: 16,
        onPressed: switch (voteState) {
          VoteState.upvoted => onRemoveUpvote,
          _ => onUpvote,
        },
      ),
    );
  }
}

class DownvotePostButton extends StatelessWidget {
  const DownvotePostButton({
    required this.voteState,
    required this.onDownvote,
    required this.onRemoveDownvote,
    super.key,
  });

  final VoteState voteState;
  final void Function() onDownvote;
  final void Function()? onRemoveDownvote;

  @override
  Widget build(BuildContext context) {
    return BooruTooltip(
      message: context.t.post.action.downvote,
      child: IconButton(
        icon: Icon(
          Symbols.arrow_downward,
          color: voteState.isDownvoted ? context.colors.downvoteColor : null,
        ),
        splashRadius: 16,
        onPressed: switch (voteState) {
          VoteState.downvoted => onRemoveDownvote,
          _ => onDownvote,
        },
      ),
    );
  }
}
