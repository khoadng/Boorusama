// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/votes/types.dart';
import '../../../core/posts/votes/widgets.dart';
import '../posts/types.dart';
import 'providers.dart';

class SzurubooruUpvotePostButton extends ConsumerWidget {
  const SzurubooruUpvotePostButton({
    super.key,
    required this.post,
  });

  final SzurubooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final postVote = ref.watch(szurubooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    final voteNotifier = ref.watch(
      szurubooruPostVotesProvider(config).notifier,
    );

    return UpvotePostButton(
      voteState: voteState,
      onUpvote: () => voteNotifier.upvote(post.id),
      onRemoveUpvote: () => voteNotifier.removeVote(post.id),
    );
  }
}

class SzurubooruDownvotePostButton extends ConsumerWidget {
  const SzurubooruDownvotePostButton({
    super.key,
    required this.post,
  });

  final SzurubooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final postVote = ref.watch(szurubooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    final voteNotifier = ref.watch(
      szurubooruPostVotesProvider(config).notifier,
    );

    return DownvotePostButton(
      voteState: voteState,
      onDownvote: () => voteNotifier.downvote(post.id),
      onRemoveDownvote: () => voteNotifier.removeVote(post.id),
    );
  }
}
