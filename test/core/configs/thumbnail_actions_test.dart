// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/configs/listing/types.dart';

void main() {
  group('profiles saved before 4.6', () {
    final cases = [
      (legacy: null, primary: ThumbnailAction.defaultAction),
      (legacy: 'toggleBookmark', primary: ThumbnailAction.bookmark),
      (legacy: 'download', primary: ThumbnailAction.download),
      (legacy: 'viewArtist', primary: ThumbnailAction.artist),
      (legacy: 'somethingElse', primary: ThumbnailAction.defaultAction),
      (legacy: '', primary: null),
    ];

    for (final c in cases) {
      test('keep ${c.legacy} as the ${c.primary} quick action', () {
        final actions = ThumbnailActions.fromConfigJson({
          'defaultPreviewImageButtonAction': ?c.legacy,
        });

        expect(actions.primary, c.primary);
        expect(actions.secondary, isNull);
      });
    }
  });

  test('saved actions load back unchanged', () {
    final cases = [
      const ThumbnailActions.none(),
      ThumbnailActions(primary: ThumbnailAction.download),
      ThumbnailActions(
        primary: ThumbnailAction.bookmark,
        secondary: ThumbnailAction.artist,
      ),
    ];

    for (final actions in cases) {
      expect(
        ThumbnailActions.fromConfigJson({
          'thumbnailActions': actions.toJson(),
          'defaultPreviewImageButtonAction': 'download',
        }),
        actions,
      );
    }
  });

  test('a repeated saved action is kept once', () {
    final actions = ThumbnailActions.fromConfigJson(const {
      'thumbnailActions': ['bookmark', 'bookmark'],
    });

    expect(actions.actions, [ThumbnailAction.bookmark]);
  });
}
