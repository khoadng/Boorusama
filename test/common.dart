// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

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
      account: Account.create('foo', 'bar', 0),
    );

class MockUserRepo extends Mock implements UserRepository {}

UserRepository mockUserRepo(List<String> tags) {
  final repo = MockUserRepo();
  when(() => repo.getUserById(any())).thenAnswer(
    (_) async => const User(
      id: 0,
      level: UserLevel.member,
      name: 'User',
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

  when(() => repo.setUserBlacklistedTags(any(), any()))
      .thenAnswer((_) async => true);

  return repo;
}
