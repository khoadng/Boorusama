// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/artists/artists.dart';

void main() {
  group('[artist commentary test]', () {
    test('empty commentary', () {
      const commentary = ArtistCommentary.empty();
      expect(
        commentary.hasCommentary,
        isFalse,
      );
    });

    test('partially empty commentary', () {
      const commentary = ArtistCommentary.description('bar');
      expect(
        commentary.hasCommentary,
        isTrue,
      );
    });

    test('commentary', () {
      const commentary = ArtistCommentary(
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
      const commentary = ArtistCommentary(
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
      const commentary = ArtistCommentary(
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
      const commentary = ArtistCommentary(
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
        const ArtistCommentary.empty(),
        const ArtistCommentary(
          originalTitle: '',
          originalDescription: '',
          translatedTitle: '',
          translatedDescription: '',
        ),
      );
    });

    test('not equal', () {
      expect(
        const ArtistCommentary.empty(),
        isNot(const ArtistCommentary(
          originalTitle: 'a',
          originalDescription: '',
          translatedTitle: '',
          translatedDescription: '',
        )),
      );
    });
  });
}
