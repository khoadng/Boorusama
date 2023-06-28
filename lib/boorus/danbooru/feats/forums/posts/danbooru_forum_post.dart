// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'danbooru_forum_post_vote.dart';

class DanbooruForumPost extends Equatable {
  const DanbooruForumPost({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.isDeleted,
    required this.topicId,
    required this.creator,
    required this.updater,
    required this.votes,
  });

  factory DanbooruForumPost.empty() => DanbooruForumPost(
        id: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        body: '',
        isDeleted: false,
        topicId: -1,
        creator: Creator.empty(),
        updater: Creator.empty(),
        votes: const [],
      );

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String body;
  final bool isDeleted;
  final int topicId;
  final Creator creator;
  final Creator updater;
  final List<DanbooruForumPostVote> votes;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        body,
        isDeleted,
        topicId,
        creator,
        updater,
        votes
      ];
}
