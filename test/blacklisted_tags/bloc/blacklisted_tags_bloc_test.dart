// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

class MockBlacklistedTagsRepository extends Mock
    implements BlacklistedTagsRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

BlacklistedTagsRepository createBlacklistedTagRepo() {
  final MockBlacklistedTagsRepository mockBlacklistedTagsRepository =
      MockBlacklistedTagsRepository();
  when(() => mockBlacklistedTagsRepository.getBlacklistedTags())
      .thenAnswer((_) async => ['foo', 'bar']);

  when(() => mockBlacklistedTagsRepository.setBlacklistedTags(any(), any()))
      .thenAnswer((_) async => true);
  return mockBlacklistedTagsRepository;
}

IAccountRepository createEmptyAccountRepo() {
  final IAccountRepository accountRepository = MockAccountRepository();
  when(() => accountRepository.get())
      .thenAnswer((invocation) => Future.value(Account.empty));
  return accountRepository;
}

IAccountRepository createUserAccountRepo() {
  final IAccountRepository accountRepository = MockAccountRepository();
  when(() => accountRepository.get()).thenAnswer((invocation) =>
      Future.value(const Account(id: 1, username: 'foo', apiKey: 'bar')));
  return accountRepository;
}

void main() {
  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when blacklisted tags requested, emit current blacklisted tags',
    build: () => BlacklistedTagsBloc(
      accountRepository: createUserAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    act: (bloc) => bloc.add(const BlacklistedTagRequested()),
    expect: () => [
      BlacklistedTagsState.initial(),
      const BlacklistedTagsState(
        blacklistedTags: ['foo', 'bar'],
        status: LoadStatus.success,
      ),
    ],
  );

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when add a tag to blacklist, emit current blacklisted tags with that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: createUserAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    act: (bloc) => bloc
      ..add(const BlacklistedTagAdded(tag: 'foo'))
      ..add(const BlacklistedTagAdded(tag: 'bar')),
    expect: () => [
      const BlacklistedTagsState(
        blacklistedTags: [],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.success,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo', 'bar'],
        status: LoadStatus.success,
      ),
    ],
  );

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when replace a tag to blacklist with a new tag, emit current blacklisted tags with that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: createUserAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    act: (bloc) => bloc
      ..add(const BlacklistedTagAdded(tag: 'foo'))
      ..add(const BlacklistedTagReplaced(oldTag: 'foo', newTag: 'bar')),
    expect: () => [
      const BlacklistedTagsState(
        blacklistedTags: [],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.success,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['bar'],
        status: LoadStatus.success,
      ),
    ],
  );

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when remove a tag from blacklist, emit current blacklisted tags without that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: createUserAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    act: (bloc) => bloc
      ..add(const BlacklistedTagAdded(tag: 'foo'))
      ..add(const BlacklistedTagAdded(tag: 'bar'))
      ..add(const BlacklistedTagRemoved(tag: 'foo')),
    expect: () => [
      const BlacklistedTagsState(
        blacklistedTags: [],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.success,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo'],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo', 'bar'],
        status: LoadStatus.success,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['foo', 'bar'],
        status: LoadStatus.loading,
      ),
      const BlacklistedTagsState(
        blacklistedTags: ['bar'],
        status: LoadStatus.success,
      ),
    ],
  );
}
