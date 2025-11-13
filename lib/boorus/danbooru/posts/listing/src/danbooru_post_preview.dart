// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/votes/types.dart';
import '../../../../../core/tags/tag/types.dart';
import '../../../../../core/themes/theme/types.dart';
import '../../../../../core/widgets/hover_aware_container.dart';
import '../../post/types.dart';
import '../../votes/providers.dart';

class DanbooruTagListPrevewTooltip extends ConsumerWidget {
  const DanbooruTagListPrevewTooltip({
    super.key,
    required this.post,
    required this.child,
  });

  final DanbooruPost post;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return PostListPrevewTooltip(
      overlayChildBuilder: (context, adjustedMaxWidth, adjustedMaxHeight) =>
          PostTagPreviewContainer(
            post: post,
            auth: config,
            maxWidth: adjustedMaxWidth,
            maxHeight: adjustedMaxHeight,
            builder: (context, tags) => DanbooruPostPreviewPopover(
              tags: tags,
              auth: ref.watchConfigAuth,
              post: post,
            ),
          ),

      child: child,
    );
  }
}

class DanbooruPostPreviewPopover extends ConsumerWidget {
  const DanbooruPostPreviewPopover({
    super.key,
    required this.tags,
    required this.auth,
    required this.post,
  });

  final List<Tag> tags;
  final BooruConfigAuth auth;
  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.listTileTheme.subtitleTextStyle?.color,
      fontSize: 11,
    );

    return PostPreviewPopover(
      tags: tags,
      auth: auth,
      header: DefaultPostPreviewHeader(
        post: post,
        auth: auth,
        style: style,
        extraWidgets: [
          _Votes(
            post: post,
            style: style,
            config: auth,
          ),
        ],
      ),
    );
  }
}

class _Votes extends ConsumerStatefulWidget {
  const _Votes({
    required this.post,
    required this.style,
    required this.config,
  });

  final DanbooruPost post;
  final TextStyle? style;
  final BooruConfigAuth config;

  @override
  ConsumerState<_Votes> createState() => __VotesState();
}

class __VotesState extends ConsumerState<_Votes> {
  @override
  Widget build(BuildContext context) {
    final params = (widget.config, widget.post.id);
    final postVote = ref.watch(danbooruPostVoteProvider(params));
    final voteState = postVote?.voteState ?? VoteState.unvote;
    final colorScheme = Theme.of(context).colorScheme;
    final postId = widget.post.id;
    final voteId = postVote?.voteId;

    return Row(
      children: [
        _VoteButton(
          onTap: voteId != null
              ? () => switch (voteState) {
                  VoteState.upvoted => ref.danbooruRemoveVote(postId, voteId),
                  _ => ref.danbooruUpvote(postId),
                }
              : null,
          child: Icon(
            Icons.arrow_upward,
            size: 13,
            color: voteState.isUpvoted
                ? context.colors.upvoteColor
                : colorScheme.hintColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            widget.post.score.toString(),
            style: widget.style,
          ),
        ),
        _VoteButton(
          onTap: voteId != null
              ? () => switch (voteState) {
                  VoteState.downvoted => ref.danbooruRemoveVote(postId, voteId),
                  _ => ref.danbooruDownvote(postId),
                }
              : null,
          child: Icon(
            Icons.arrow_downward,
            size: 13,
            color: voteState.isDownvoted
                ? context.colors.downvoteColor
                : colorScheme.hintColor,
          ),
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HoverAwareContainer(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: child,
        ),
      ),
    );
  }
}
