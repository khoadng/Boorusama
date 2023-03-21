// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/domain/boorus.dart';

class MockCurrentUserBooruRepository extends Mock
    implements CurrentUserBooruRepository {}

CurrentUserBooruRepository mockUserBooruRepo({
  UserBooru? userBooru,
}) {
  final repo = MockCurrentUserBooruRepository();
  when(() => repo.get()).thenAnswer((_) async =>
      userBooru ??
      const UserBooru(
        id: 0,
        booruId: 0,
        apiKey: '',
        login: '',
        booruUserId: 0,
      ));

  return repo;
}

CurrentUserBooruRepository fakeCurrentUserBooruRepo() => mockUserBooruRepo(
      userBooru: const UserBooru(
        id: 1,
        booruId: 1,
        apiKey: 'apiKey',
        login: 'login',
        booruUserId: 1,
      ),
    );

class MockUserRepo extends Mock implements UserRepository {}

UserRepository mockUserRepo(List<String> tags) {
  final repo = MockUserRepo();
  when(() => repo.getUserById(any())).thenAnswer(
    (_) async => User(
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
    ),
  );

  when(() => repo.getUserSelfById(any())).thenAnswer(
    (_) async => UserSelf(
      id: 0,
      level: UserLevel.member,
      name: 'User',
      blacklistedTags: tags,
    ),
  );

  return repo;
}
