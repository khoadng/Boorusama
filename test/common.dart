// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/danbooru/feat/users/users.dart';

class MockBooruUserIdentityProvider extends Mock
    implements BooruUserIdentityProvider {}

class MockUserRepo extends Mock implements UserRepository {}

BooruUserIdentityProvider createIdentityProvider() {
  final mock = MockBooruUserIdentityProvider();

  when(() => mock.getAccountIdFromConfig(any()))
      .thenAnswer((invocation) async => 1);

  return mock;
}

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
