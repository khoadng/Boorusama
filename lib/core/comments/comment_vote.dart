// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';

enum CommentVoteState {
  unvote,
  downvoted,
  upvoted,
}

abstract class CommentVote {
  int get commentId;
  int get score;
}

abstract class CommentVoteRepository<T extends CommentVote> {
  Future<List<T>> getCommentVotes(List<int> commentIds);
  Future<T> upvoteComment(int commentId);
  Future<T> downvoteComment(int commentId);
  Future<bool> unvoteComment(int commentId);
}

class CommentVoteRepositoryBuilder<T extends CommentVote>
    with CacheMixin<T>
    implements CommentVoteRepository<T> {
  CommentVoteRepositoryBuilder({
    required this.fetch,
    required this.unvote,
    required this.upvote,
    required this.downvote,
  });

  final Future<List<T>> Function(List<int> commentIds) fetch;
  final Future<T> Function(int commentId) upvote;
  final Future<T> Function(int commentId) downvote;
  final Future<bool> Function(int commentId) unvote;

  @override
  Future<List<T>> getCommentVotes(List<int> commentIds) async {
    final cachedVotes = <T>[];
    final notInCache = <int>[];
    for (final id in commentIds) {
      final cached = get('comment_$id');

      if (cached != null) {
        cachedVotes.add(cached);
      } else {
        notInCache.add(id);
      }
    }

    if (notInCache.isEmpty) return Future.value(cachedVotes);

    final freshVotes = await fetch(notInCache);

    for (final vote in freshVotes) {
      set('comment_${vote.commentId}', vote);
    }

    return [...cachedVotes, ...freshVotes];
  }

  @override
  Future<T> downvoteComment(int commentId) {
    remove('comment_$commentId');

    return downvote(commentId);
  }

  @override
  Future<bool> unvoteComment(int commentId) {
    remove('comment_$commentId');

    return unvote(commentId);
  }

  @override
  Future<T> upvoteComment(int commentId) {
    remove('comment_$commentId');

    return upvote(commentId);
  }

  @override
  int get maxCapacity => 1000;

  @override
  Duration get staleDuration => const Duration(minutes: 10);
}
