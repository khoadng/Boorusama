// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('[tag bloc, happy path test]', () {
    final tagRepo = MockTagRepository();

    blocTest<TagBloc, TagState>(
      'fetch 2 tags',
      setUp: () {
        when(() => tagRepo.getTagsByNameComma(any(), any()))
            .thenAnswer((invocation) async => [
                  Tag.empty().copyWith('foo', TagCategory.general, 100),
                  Tag.empty().copyWith('bar', TagCategory.artist, 200),
                ]);
      },
      build: () => TagBloc(tagRepository: tagRepo),
      act: (bloc) => bloc.add(const TagFetched(tags: ['foo', 'bar'])),
      expect: () => [
        TagState.initial().copyWith(status: LoadStatus.loading),
        TagState.initial().copyWith(
          status: LoadStatus.success,
          tags: [
            TagGroupItem(
              groupName: 'Artist',
              tags: [Tag.empty().copyWith('bar', TagCategory.artist, 200)],
              order: 0,
            ),
            TagGroupItem(
              groupName: 'General',
              tags: [Tag.empty().copyWith('foo', TagCategory.general, 100)],
              order: 3,
            ),
          ],
        ),
      ],
    );
  });

  group('[tag category to String test]', () {
    test('map string correctly', () {
      final input = {
        TagCategory.artist: 'Artist',
        TagCategory.charater: 'Character',
        TagCategory.general: 'General',
        TagCategory.meta: 'Meta',
        TagCategory.copyright: 'Copyright',
        TagCategory.invalid_: '',
      };

      expect(
        input.keys
            .map((e) => Tuple2(tagCategoryToString(e), e))
            .every((e) => e.item1 == input[e.item2]),
        isTrue,
      );
    });
  });
}
