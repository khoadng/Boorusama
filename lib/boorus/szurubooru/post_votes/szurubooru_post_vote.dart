// Package imports:

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/clients/szurubooru/types/types.dart';
import 'package:boorusama/core/posts/posts.dart';
import '../szurubooru_post.dart';

class SzurubooruPostVote extends Equatable implements PostVote {
  const SzurubooruPostVote({
    required this.id,
    required this.postId,
    required this.score,
  });

  const SzurubooruPostVote.local({
    required this.postId,
    required this.score,
  }) : id = kLocalPostVoteId;

  factory SzurubooruPostVote.fromPostDto(PostDto post) => SzurubooruPostVote(
        id: post.id ?? kLocalPostVoteId,
        postId: post.id ?? -1,
        score: post.score ?? 0,
      );

  factory SzurubooruPostVote.fromPost(SzurubooruPost post) =>
      SzurubooruPostVote(
        id: post.id,
        postId: post.id,
        score: post.score,
      );

  @override
  final int id;
  @override
  final int postId;
  @override
  final int score;

  @override
  List<Object?> get props => [id, postId, score];
}
