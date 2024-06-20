// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/forums/forums.dart';
import 'danbooru_forum_post_vote.dart';

class DanbooruForumPost extends Equatable implements ForumPost {
  const DanbooruForumPost({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.isDeleted,
    required this.topicId,
    required this.creatorId,
    required this.updaterId,
    required this.votes,
  });

  factory DanbooruForumPost.empty() => DanbooruForumPost(
        id: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        body: '',
        isDeleted: false,
        topicId: -1,
        creatorId: -1,
        updaterId: -1,
        votes: const [],
      );

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String body;
  final bool isDeleted;
  final int topicId;
  final List<DanbooruForumPostVote> votes;

  @override
  final int creatorId;
  final int updaterId;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        body,
        isDeleted,
        topicId,
        creatorId,
        updaterId,
        votes
      ];
}
