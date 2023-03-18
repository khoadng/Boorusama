// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import '../../common.dart';

class MockBlacklistedTagsRepository extends Mock
    implements BlacklistedTagsRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

BlacklistedTagsRepository createBlacklistedTagRepo() {
  final MockBlacklistedTagsRepository mockBlacklistedTagsRepository =
      MockBlacklistedTagsRepository();
  when(() => mockBlacklistedTagsRepository.getBlacklistedTags(any()))
      .thenAnswer((_) async => ['foo', 'bar']);

  when(() => mockBlacklistedTagsRepository.setBlacklistedTags(any(), any()))
      .thenAnswer((_) async => true);

  return mockBlacklistedTagsRepository;
}

void main() {
  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when blacklisted tags requested, emit current blacklisted tags',
    build: () => BlacklistedTagsBloc(
      accountRepository: fakeAccountRepo(),
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

  Completer? completer;

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when add a tag to blacklist, emit current blacklisted tags with that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: fakeAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    seed: () =>
        BlacklistedTagsState.initial().copyWith(blacklistedTags: () => []),
    setUp: () => completer = Completer<List<String>>(),
    tearDown: () => completer = null,
    act: (bloc) => bloc
      ..add(BlacklistedTagAdded(tag: 'bar', onSuccess: completer!.complete)),
    verify: (bloc) => expect(completer!.isCompleted, true),
  );

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when replace a tag to blacklist with a new tag, emit current blacklisted tags with that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: fakeAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    seed: () =>
        BlacklistedTagsState.initial().copyWith(blacklistedTags: () => []),
    setUp: () => completer = Completer<List<String>>(),
    tearDown: () => completer = null,
    act: (bloc) => bloc
      ..add(const BlacklistedTagAdded(tag: 'foo'))
      ..add(BlacklistedTagReplaced(
        oldTag: 'foo',
        newTag: 'bar',
        onSuccess: completer!.complete,
      )),
    verify: (bloc) => expect(completer!.isCompleted, true),
  );

  blocTest<BlacklistedTagsBloc, BlacklistedTagsState>(
    'when remove a tag from blacklist, emit current blacklisted tags without that tag',
    build: () => BlacklistedTagsBloc(
      accountRepository: fakeAccountRepo(),
      blacklistedTagsRepository: createBlacklistedTagRepo(),
    ),
    seed: () => BlacklistedTagsState.initial()
        .copyWith(blacklistedTags: () => ['foo', 'bar']),
    setUp: () => completer = Completer<List<String>>(),
    tearDown: () => completer = null,
    act: (bloc) => bloc
      ..add(BlacklistedTagRemoved(
        tag: 'foo',
        onSuccess: completer!.complete,
      )),
    verify: (bloc) {
      expect(completer!.isCompleted, true);
    },
  );
}
