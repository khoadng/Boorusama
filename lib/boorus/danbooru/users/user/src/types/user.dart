// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/users/user.dart';
import 'user_level.dart';

String getDanbooruProfileUrl(String url) =>
    url.endsWith('/') ? '${url}profile' : '$url/profile';

class DanbooruUser extends Equatable implements User {
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

  @override
  final UserId id;
  final UserLevel level;
  @override
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

  bool get hasFeedbacks =>
      sumInt(
        [
          positiveFeedbackCount,
          neutralFeedbackCount,
          negativeFeedbackCount,
        ],
      ) >
      0;

  bool get hasEdits => tagEditCount > 0;
  bool get hasUploads => uploadCount > 0;

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
  }) => DanbooruUser(
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
  @override
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
  }) => UserSelf(
    id: id ?? this.id,
    level: level ?? this.level,
    name: name ?? this.name,
    blacklistedTags: blacklistedTags,
  );
}

typedef UserId = int;
typedef Username = String;
