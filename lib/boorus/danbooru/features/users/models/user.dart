// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';
import 'user_level.dart';
import 'user_repository.dart';

class User extends Equatable {
  const User({
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

  factory User.placeholder() => User(
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

extension UserX on User {
  User copyWith({
    UserId? id,
    UserLevel? level,
    Username? name,
    DateTime? joinedDate,
  }) =>
      User(
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

List<String> tagStringToListTagString(String str) => str.split('\n');

Future<List<User>> Function(List<Favorite> favs) createUserWith(
  UserRepository userRepository,
) =>
    (favs) async {
      if (favs.isEmpty) {
        return [];
      }

      return userRepository.getUsersByIdStringComma(
        favs.map((e) => e.userId).join(','),
      );
    };
