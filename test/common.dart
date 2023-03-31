// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/domain/boorus.dart';

class MockCurrentUserBooruRepository extends Mock
    implements CurrentBooruConfigRepository {}

CurrentBooruConfigRepository mockUserBooruRepo({
  BooruConfig? booruConfig,
}) {
  final repo = MockCurrentUserBooruRepository();
  when(() => repo.get()).thenAnswer((_) async =>
      booruConfig ??
      const BooruConfig(
        id: 0,
        booruId: 0,
        apiKey: '',
        login: '',
        url: '',
        booruUserId: 0,
        deletedItemBehavior: BooruConfigDeletedItemBehavior.hide,
        name: '',
        ratingFilter: BooruConfigRatingFilter.none,
      ));

  return repo;
}

CurrentBooruConfigRepository fakeCurrentUserBooruRepo() => mockUserBooruRepo(
      booruConfig: const BooruConfig(
        id: 1,
        booruId: 1,
        apiKey: 'apiKey',
        login: 'login',
        url: '',
        booruUserId: 1,
        deletedItemBehavior: BooruConfigDeletedItemBehavior.hide,
        name: 'foo',
        ratingFilter: BooruConfigRatingFilter.none,
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
