// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../core/posts/votes/types.dart';
import '../../../users/user/types.dart';

export 'package:booru_clients/danbooru.dart' show PostVoteId;

const _localPostVote = PostVoteId.fromInt(-99);

class DanbooruPostVote extends Equatable implements PostVote {
  const DanbooruPostVote({
    required this.voteId,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  factory DanbooruPostVote.empty() => DanbooruPostVote(
    voteId: const PostVoteId.fromInt(-1),
    postId: -1,
    userId: -1,
    createdAt: DateTime(1),
    updatedAt: DateTime(1),
    score: -9999,
    isDeleted: false,
  );

  factory DanbooruPostVote.local({
    required int postId,
    required int score,
  }) => DanbooruPostVote(
    voteId: _localPostVote,
    postId: postId,
    userId: -99,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    score: score,
    isDeleted: false,
  );

  @override
  int get id => voteId.value;
  @override
  final int postId;
  final UserId userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  @override
  final int score;
  final bool isDeleted;
  final PostVoteId voteId;

  static bool isLocalVote(PostVoteId id) => id == _localPostVote;

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    createdAt,
    updatedAt,
    score,
    isDeleted,
  ];
}

extension PostVoteX on DanbooruPostVote {
  bool get isOptimisticUpdateVote =>
      id == DanbooruPostVote.local(postId: postId, score: score).id;

  DanbooruPostVote copyWith({
    PostVoteId? voteId,
    int? postId,
    UserId? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? score,
    bool? isDeleted,
  }) => DanbooruPostVote(
    voteId: voteId ?? this.voteId,
    postId: postId ?? this.postId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    score: score ?? this.score,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}
