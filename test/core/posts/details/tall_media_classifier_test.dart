// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/posts/details/src/utils/tall_media_classifier.dart';
import 'package:boorusama/core/settings/src/types/settings.dart';

void main() {
  const settings = TallMediaSettings.defaults();

  test('marks extremely tall images as tall', () {
    final disposition = classifyTallMedia(
      settings: settings,
      viewportSize: const Size(1080, 1920),
      width: 1200,
      height: 4200,
      isVideo: false,
    );

    expect(disposition.isTall, isTrue);
    expect(disposition.shouldFitToWidth, isTrue);
    expect(disposition.hasScrollableExtent, isTrue);
  });

  test('does not mark marginal aspect ratios as tall', () {
    final disposition = classifyTallMedia(
      settings: settings,
      viewportSize: const Size(1080, 1920),
      width: 900,
      height: 1500,
      isVideo: false,
    );

    expect(disposition.isTall, isFalse);
    expect(disposition.shouldFitToWidth, isFalse);
  });

  test('requires sufficient pixel density to be considered tall', () {
    final disposition = classifyTallMedia(
      settings: settings,
      viewportSize: const Size(720, 1280),
      width: 420,
      height: 1600,
      isVideo: false,
    );

    expect(disposition.isTall, isFalse);
  });

  test('ignores tall originals when scaled height fits viewport', () {
    final disposition = classifyTallMedia(
      settings: settings,
      viewportSize: const Size(1080, 1920),
      width: 4200,
      height: 2800,
      isVideo: false,
    );

    expect(disposition.isTall, isFalse);
  });

  test('videos are never classified as tall still images', () {
    final disposition = classifyTallMedia(
      settings: settings,
      viewportSize: const Size(1080, 1920),
      width: 1080,
      height: 3600,
      isVideo: true,
    );

    expect(disposition.isTall, isFalse);
  });

  test('disabled setting prevents tall classification', () {
    const disabledSettings = TallMediaSettings(enabled: false);

    final disposition = classifyTallMedia(
      settings: disabledSettings,
      viewportSize: const Size(1080, 1920),
      width: 1200,
      height: 4200,
      isVideo: false,
    );

    expect(disposition.isTall, isFalse);
    expect(disposition.shouldFitToWidth, isFalse);
  });
}
