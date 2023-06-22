// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';

void main() {
  group('[artist commentary test]', () {
    test('empty commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: '',
        originalDescription: '',
        translatedTitle: '',
        translatedDescription: '',
      );
      expect(
        commentary.hasCommentary,
        isFalse,
      );
    });

    test('partially empty commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: '',
        originalDescription: 'bar',
        translatedTitle: '',
        translatedDescription: '',
      );
      expect(
        commentary.hasCommentary,
        isTrue,
      );
    });

    test('commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: 'foo',
        originalDescription: 'bar',
        translatedTitle: '',
        translatedDescription: '',
      );
      expect(
        commentary.hasCommentary,
        isTrue,
      );
    });

    test('untranslated commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: 'foo',
        originalDescription: 'bar',
        translatedTitle: '',
        translatedDescription: '',
      );
      expect(
        commentary.isTranslated,
        isFalse,
      );
    });

    test('translated commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: 'foo',
        originalDescription: 'bar',
        translatedTitle: 'some title',
        translatedDescription: 'some desc',
      );
      expect(
        commentary.isTranslated,
        isTrue,
      );
    });

    test('partially translated commentary', () {
      const commentary = DanbooruArtistCommentary(
        originalTitle: 'foo',
        originalDescription: 'bar',
        translatedTitle: '',
        translatedDescription: 'some desc',
      );
      expect(
        commentary.isTranslated,
        isTrue,
      );
    });
  });

  group('[artist commentary comparison tests]', () {
    test('equal', () {
      expect(
        DanbooruArtistCommentary.empty(),
        const DanbooruArtistCommentary(
          originalTitle: '',
          originalDescription: '',
          translatedTitle: '',
          translatedDescription: '',
        ),
      );
    });

    test('not equal', () {
      expect(
        DanbooruArtistCommentary.empty(),
        isNot(const DanbooruArtistCommentary(
          originalTitle: 'a',
          originalDescription: '',
          translatedTitle: '',
          translatedDescription: '',
        )),
      );
    });
  });
}
