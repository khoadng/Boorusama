// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'user.dart';
import 'user_level.dart';
import 'user_self.dart';

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
