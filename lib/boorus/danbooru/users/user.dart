// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'user_level.dart';
import 'user_repository.dart';

class DanbooruUser extends Equatable {
  const DanbooruUser({
    required this.id,
    required this.level,
    required this.name,
    required this.joinedDate,
    required this.uploadCount,
    required this.tagEditCount,
    required this.noteEditCount,
    required this.commentCount,
    required this.forumPostCount,
    required this.favoriteGroupCount,
  });

  factory DanbooruUser.placeholder() => DanbooruUser(
        id: 0,
        level: UserLevel.member,
        name: 'User',
        joinedDate: DateTime(1),
        uploadCount: 0,
        tagEditCount: 0,
        noteEditCount: 0,
        commentCount: 0,
        forumPostCount: 0,
        favoriteGroupCount: 0,
      );

  final UserId id;
  final UserLevel level;
  final Username name;
  final DateTime joinedDate;
  final int uploadCount;
  final int tagEditCount;
  final int noteEditCount;
  final int commentCount;
  final int forumPostCount;
  final int favoriteGroupCount;

  @override
  List<Object?> get props => [
        id,
        level,
        name,
        joinedDate,
        uploadCount,
        tagEditCount,
        noteEditCount,
        commentCount,
        forumPostCount,
        favoriteGroupCount,
      ];
}

extension UserX on DanbooruUser {
  DanbooruUser copyWith({
    UserId? id,
    UserLevel? level,
    Username? name,
    DateTime? joinedDate,
  }) =>
      DanbooruUser(
        id: id ?? this.id,
        level: level ?? this.level,
        name: name ?? this.name,
        joinedDate: joinedDate ?? this.joinedDate,
        uploadCount: uploadCount,
        tagEditCount: tagEditCount,
        noteEditCount: noteEditCount,
        commentCount: commentCount,
        forumPostCount: forumPostCount,
        favoriteGroupCount: favoriteGroupCount,
      );
}

typedef UserId = int;
typedef Username = String;

Set<String> tagStringToListTagString(String str) => str.split('\n').toSet();

Future<List<DanbooruUser>> Function(List<Favorite> favs) createUserWith(
  UserRepository userRepository,
) =>
    (favs) async {
      if (favs.isEmpty) {
        return [];
      }

      return userRepository.getUsersByIds(
        favs.map((e) => e.userId).toList(),
      );
    };
