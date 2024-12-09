// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/users/user.dart';
import '../../posts/favorites/favorite.dart';
import '../level/user_level.dart';

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
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
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
        positiveFeedbackCount: 0,
        neutralFeedbackCount: 0,
        negativeFeedbackCount: 0,
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
  final int positiveFeedbackCount;
  final int neutralFeedbackCount;
  final int negativeFeedbackCount;

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
        positiveFeedbackCount,
        neutralFeedbackCount,
        negativeFeedbackCount,
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
        positiveFeedbackCount: positiveFeedbackCount,
        neutralFeedbackCount: neutralFeedbackCount,
        negativeFeedbackCount: negativeFeedbackCount,
      );
}

class UserSelf extends Equatable implements User {
  const UserSelf({
    required this.id,
    required this.level,
    required this.name,
    required this.blacklistedTags,
  });

  factory UserSelf.placeholder() => const UserSelf(
        id: 0,
        level: UserLevel.member,
        name: 'User',
        blacklistedTags: {},
      );

  @override
  final UserId id;
  final UserLevel level;
  final Username name;
  final Set<String> blacklistedTags;

  @override
  List<Object?> get props => [id, level, name, blacklistedTags];
}

extension UserSelfX on UserSelf {
  UserSelf copyWith({
    UserId? id,
    UserLevel? level,
    Username? name,
  }) =>
      UserSelf(
        id: id ?? this.id,
        level: level ?? this.level,
        name: name ?? this.name,
        blacklistedTags: blacklistedTags,
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

abstract class UserRepository {
  Future<List<DanbooruUser>> getUsersByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  });
  Future<DanbooruUser> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}

DanbooruUser userDtoToUser(
  UserDto d,
) {
  return DanbooruUser(
    id: d.id ?? 0,
    level: intToUserLevel(d.level ?? 0),
    name: d.name ?? 'User',
    joinedDate: d.createdAt ?? DateTime.now(),
    uploadCount: d.uploadCount ?? 0,
    tagEditCount: d.tagEditCount ?? 0,
    noteEditCount: d.noteEditCount ?? 0,
    commentCount: d.commentCount ?? 0,
    forumPostCount: d.forumPostCount ?? 0,
    favoriteGroupCount: d.favoriteGroupCount ?? 0,
    positiveFeedbackCount: d.positiveFeedbackCount ?? 0,
    neutralFeedbackCount: d.neutralFeedbackCount ?? 0,
    negativeFeedbackCount: d.negativeFeedbackCount ?? 0,
  );
}

UserSelf userDtoToUserSelf(
  UserSelfDto d,
  Set<String> defaultBlacklistedTags,
) {
  return UserSelf(
    id: d.id ?? 0,
    level: intToUserLevel(d.level ?? 0),
    name: d.name ?? 'User',
    blacklistedTags: d.blacklistedTags == null
        ? defaultBlacklistedTags
        : tagStringToListTagString(d.blacklistedTags ?? ''),
  );
}

List<DanbooruUser> parseUsers(List<UserDto> value) =>
    value.map(userDtoToUser).toList();
