// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

void main() {
  group('[vote state test]', () {
    test('upvoted', () {
      final vote = DanbooruPostVote.empty().copyWith(score: 1);

      expect(vote.voteState, equals(VoteState.upvoted));
    });

    test('downvoted', () {
      final vote = DanbooruPostVote.empty().copyWith(score: -1);

      expect(vote.voteState, equals(VoteState.downvoted));
    });

    test('unvoted', () {
      final votes =
          [0].map((e) => DanbooruPostVote.empty().copyWith(score: e)).toList();

      expect(votes.every((vote) => vote.voteState == VoteState.unvote), isTrue);
    });
  });
}
