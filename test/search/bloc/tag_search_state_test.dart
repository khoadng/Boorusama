// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import '../common.dart';

class MockAutocompleteRepository extends Mock
    implements AutocompleteRepository {}

void main() {
  group('Tag search', () {
    final autocompleteRepository = MockAutocompleteRepository();
    const tagInfo = TagInfo(
      metatags: [],
      defaultBlacklistedTags: [],
      r18Tags: [],
    );

    when(() => autocompleteRepository.getAutocomplete('a'))
        .thenAnswer((_) async => [autocompleteData('a')]);
    when(() => autocompleteRepository.getAutocomplete('a_a_a'))
        .thenAnswer((_) async => [autocompleteData('a_a_a')]);
    TagSearchBloc bloc() => TagSearchBloc(
          autocompleteRepository: autocompleteRepository,
          tagInfo: tagInfo,
        );

    TagSearchItem tagSearchItem(AutocompleteData data) =>
        TagSearchItem.fromString(
          autocompleteData().value,
          tagInfo,
        );

    blocTest<TagSearchBloc, TagSearchState>(
      'when new tag selected, add to selected tags',
      build: () => bloc(),
      act: (bloc) => bloc.add(TagSearchNewTagSelected(autocompleteData())),
      expect: () => [
        TagSearchState.initial().copyWith(
          selectedTags: [
            tagSearchItem(autocompleteData()),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when tag removed, remove from selected tags',
      build: () => bloc()
        ..emit(tagSearchStateEmpty().copyWith(
          selectedTags: [tagSearchItem(autocompleteData())],
        )),
      act: (bloc) => bloc
          .add(TagSearchSelectedTagRemoved(tagSearchItem(autocompleteData()))),
      expect: () => [tagSearchStateEmpty()],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when cleared, query should be empty',
      build: () => bloc()
        ..emit(tagSearchStateEmpty().copyWith(
          query: 'foo',
        )),
      act: (bloc) => bloc.add(const TagSearchCleared()),
      expect: () => [tagSearchStateEmpty().copyWith(query: '')],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when selected from history, tags should be added to selected tags',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchTagFromHistorySelected('foo bar')),
      expect: () => [
        tagSearchStateEmpty().copyWith(
          selectedTags: [
            tagSearchItemFromString('foo'),
            tagSearchItemFromString('bar'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when raw tag is selected, it should be added to selected tags',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchNewRawStringTagSelected('foo')),
      expect: () => [
        tagSearchStateEmpty().copyWith(
          selectedTags: [
            tagSearchItemFromString('foo'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when raw tags are selected, it should be added to selected tags',
      build: () => bloc(),
      act: (bloc) =>
          bloc.add(const TagSearchNewRawStringTagsSelected(['foo', 'bar'])),
      expect: () => [
        tagSearchStateEmpty().copyWith(
          selectedTags: [
            tagSearchItemFromString('foo'),
            tagSearchItemFromString('bar'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when user submit tag without using suggestion, it should be added to selected tags',
      build: () => bloc()..emit(tagSearchStateEmpty().copyWith(query: 'foo')),
      act: (bloc) => bloc.add(const TagSearchSubmitted()),
      expect: () => [
        tagSearchStateEmpty().copyWith(
          selectedTags: [
            tagSearchItemFromString('foo'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when query is empty, state should be the same',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchChanged('')),
      expect: () => [tagSearchStateEmpty()],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when query start with a single operator, emit no state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchChanged('-')),
      expect: () => [],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when a non-operator character is added, suggestion should have value',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchChanged('a')),
      expect: () => [
        tagSearchStateEmpty().copyWith(query: 'a'),
        tagSearchStateEmpty().copyWith(
          query: 'a',
          suggestionTags: [
            autocompleteData('a'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when a tag is added, replace all whitespace with underscore',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchChanged('a a a')),
      expect: () => [
        tagSearchStateEmpty().copyWith(query: 'a_a_a'),
        tagSearchStateEmpty().copyWith(
          query: 'a_a_a',
          suggestionTags: [
            autocompleteData('a_a_a'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      'when a tag is added, trim the leading whitespace',
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchChanged(' a')),
      expect: () => [
        tagSearchStateEmpty().copyWith(query: 'a'),
        tagSearchStateEmpty().copyWith(
          query: 'a',
          suggestionTags: [
            autocompleteData('a'),
          ],
        ),
      ],
    );

    blocTest<TagSearchBloc, TagSearchState>(
      "when user end searching, emitted 'done' signal",
      build: () => bloc(),
      act: (bloc) => bloc.add(const TagSearchDone()),
      expect: () => [
        tagSearchStateEmpty().copyWith(isDone: true),
      ],
    );
  });
}
