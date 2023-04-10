// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';

class MockFavoriteTagRepository extends Mock implements FavoriteTagRepository {}

void main() {
  final favTagRepo = MockFavoriteTagRepository();

  blocTest<FavoriteTagBloc, FavoriteTagState>(
    'fetch all tags',
    setUp: () {
      when(() => favTagRepo.getAll()).thenAnswer((invocation) async => [
            FavoriteTag.empty(),
          ]);
    },
    tearDown: () {
      reset(favTagRepo);
    },
    build: () => FavoriteTagBloc(
      favoriteTagRepository: favTagRepo,
    ),
    act: (bloc) => bloc.add(const FavoriteTagFetched()),
    expect: () => [
      FavoriteTagState.initial().copyWith(tags: [
        FavoriteTag.empty(),
      ]),
    ],
  );

  blocTest<FavoriteTagBloc, FavoriteTagState>(
    'add tag',
    setUp: () {
      when(() => favTagRepo.getAll()).thenAnswer((invocation) async => [
            FavoriteTag.empty().copyWith(name: 'foo'),
          ]);
      when(() => favTagRepo.create(name: any(named: 'name'))).thenAnswer(
        (invocation) async => FavoriteTag.empty().copyWith(name: 'foo'),
      );
    },
    tearDown: () {
      reset(favTagRepo);
    },
    build: () => FavoriteTagBloc(
      favoriteTagRepository: favTagRepo,
    ),
    act: (bloc) => bloc.add(const FavoriteTagAdded(tag: 'foo')),
    verify: (bloc) =>
        verify(() => favTagRepo.create(name: any(named: 'name'))).called(1),
    expect: () => [
      FavoriteTagState.initial().copyWith(tags: [
        FavoriteTag.empty().copyWith(name: 'foo'),
      ]),
    ],
  );

  blocTest<FavoriteTagBloc, FavoriteTagState>(
    'remove tag',
    setUp: () {
      when(() => favTagRepo.getAll()).thenAnswer((invocation) async => []);
      when(() => favTagRepo.deleteFirst(any())).thenAnswer(
        (invocation) async => FavoriteTag.empty().copyWith(name: 'foo'),
      );
    },
    tearDown: () {
      reset(favTagRepo);
    },
    seed: () => FavoriteTagState.initial().copyWith(tags: [
      FavoriteTag.empty().copyWith(name: 'foo'),
    ]),
    build: () => FavoriteTagBloc(
      favoriteTagRepository: favTagRepo,
    ),
    act: (bloc) => bloc.add(const FavoriteTagRemoved(index: 0)),
    verify: (bloc) => verify(() => favTagRepo.deleteFirst(any())).called(1),
    expect: () => [
      FavoriteTagState.initial(),
    ],
  );

  blocTest<FavoriteTagBloc, FavoriteTagState>(
    'import tag',
    setUp: () {
      when(() => favTagRepo.getAll()).thenAnswer((invocation) async => [
            FavoriteTag.empty().copyWith(name: '0'),
            FavoriteTag.empty().copyWith(name: '1'),
            FavoriteTag.empty().copyWith(name: '2'),
          ]);
      when(() => favTagRepo.create(name: any(named: 'name'))).thenAnswer(
        (invocation) async => FavoriteTag.empty().copyWith(name: '0'),
      );
    },
    tearDown: () {
      reset(favTagRepo);
    },
    seed: () => FavoriteTagState.initial().copyWith(tags: [
      FavoriteTag.empty().copyWith(name: '0'),
    ]),
    build: () => FavoriteTagBloc(
      favoriteTagRepository: favTagRepo,
    ),
    act: (bloc) => bloc.add(const FavoriteTagImported(tagString: '1 2')),
    verify: (bloc) =>
        verify(() => favTagRepo.create(name: any(named: 'name'))).called(2),
    expect: () => [
      FavoriteTagState.initial().copyWith(tags: [
        FavoriteTag.empty().copyWith(name: '0'),
        FavoriteTag.empty().copyWith(name: '1'),
        FavoriteTag.empty().copyWith(name: '2'),
      ]),
    ],
  );
}
