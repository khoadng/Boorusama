// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/boorus.dart';

class MockAccountRepo extends Mock implements AccountRepository {}

AccountRepository mockAccountRepo({
  Account? account,
}) {
  final repo = MockAccountRepo();
  when(() => repo.get()).thenAnswer((_) async => account ?? Account.empty);

  return repo;
}

AccountRepository emptyAccountRepo() => mockAccountRepo();
AccountRepository fakeAccountRepo() => mockAccountRepo(
      account: Account.create('foo', 'bar', 0, BooruType.unknown),
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
