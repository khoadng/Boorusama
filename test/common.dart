// Package imports:
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class MockAccountRepo extends Mock implements IAccountRepository {}

IAccountRepository mockAccountRepo({
  Account? account,
}) {
  final repo = MockAccountRepo();
  when(() => repo.get()).thenAnswer((_) async => account ?? Account.empty);
  return repo;
}

IAccountRepository emptyAccountRepo() => mockAccountRepo();
IAccountRepository fakeAccountRepo() => mockAccountRepo(
      account: Account.create('foo', 'bar', 0),
    );

class MockUserRepo extends Mock implements IUserRepository {}

IUserRepository mockUserRepo(List<String> tags) {
  final repo = MockUserRepo();
  when(() => repo.getUserById(any())).thenAnswer(
    (_) async => User(
      id: const UserId(0),
      level: UserLevel.member,
      name: const Username('User'),
      blacklistedTags: tags,
    ),
  );

  when(() => repo.setUserBlacklistedTags(any(), any()))
      .thenAnswer((_) async => true);
  return repo;
}
