// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/user.dart';
import '../types/user_level.dart';

DanbooruUser userDtoToUser(
  UserDto d,
) {
  return DanbooruUser(
    id: d.id ?? 0,
    level: UserLevel.parse(d.level),
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
    level: UserLevel.parse(d.level),
    name: d.name ?? 'User',
    blacklistedTags: d.blacklistedTags == null
        ? defaultBlacklistedTags
        : tagStringToListTagString(d.blacklistedTags ?? ''),
  );
}

List<DanbooruUser> parseUsers(List<UserDto> value) =>
    value.map(userDtoToUser).toList();

Set<String> tagStringToListTagString(String str) => str.split('\n').toSet();
