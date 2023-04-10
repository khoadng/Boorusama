// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/core/domain/settings.dart';

void main() {
  group('action bar visibility tests', () {
    test('slideshow enabled => hide', () {
      expect(
        PostDetailState.initial()
            .copyWith(enableSlideShow: true)
            .shouldShowFloatingActionBar(ActionBarDisplayBehavior.scrolling),
        false,
      );
    });

    test('slideshow disable, overlay off => hide', () {
      expect(
        PostDetailState.initial()
            .copyWith(
              enableSlideShow: false,
              enableOverlay: false,
            )
            .shouldShowFloatingActionBar(ActionBarDisplayBehavior.scrolling),
        false,
      );
    });

    test('slideshow disable, overlay on, users default as static => show', () {
      expect(
        PostDetailState.initial()
            .copyWith(
              enableSlideShow: false,
              enableOverlay: true,
            )
            .shouldShowFloatingActionBar(
              ActionBarDisplayBehavior.staticAtBottom,
            ),
        true,
      );
    });

    test(
      'slideshow disable, overlay on, users default as scrolling, in fullscreen => show',
      () {
        expect(
          PostDetailState.initial()
              .copyWith(
                enableSlideShow: false,
                enableOverlay: true,
                fullScreen: true,
              )
              .shouldShowFloatingActionBar(ActionBarDisplayBehavior.scrolling),
          true,
        );
      },
    );

    test(
      'slideshow disable, overlay on, users default as scrolling, not in fullscreen => hide',
      () {
        expect(
          PostDetailState.initial()
              .copyWith(
                enableSlideShow: false,
                enableOverlay: true,
                fullScreen: false,
              )
              .shouldShowFloatingActionBar(ActionBarDisplayBehavior.scrolling),
          false,
        );
      },
    );
  });
}
