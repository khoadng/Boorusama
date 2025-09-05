// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/videos/src/types/booru_player.dart';
import 'package:boorusama/core/videos/src/types/video_player_state.dart';

// Test constants
const kTestWebmUrl = 'https://example.com/video.webm';
const kTestMp4Url = 'https://example.com/video.mp4';
const kTestThumbnailUrl = 'https://example.com/thumb.jpg';

class MockBooruPlayer extends Mock implements BooruPlayer {}

void main() {
  group('VideoPlayerState.resolveVideoEngine', () {
    test('should return webview for .webm files on Android when auto', () {
      final result = VideoPlayerState.resolveVideoEngine(
        engine: VideoPlayerEngine.auto,
        url: kTestWebmUrl,
        isAndroid: true,
      );

      expect(result, VideoPlayerEngine.webview);
    });

    test(
      'should return videoPlayerPlugin for .webm files on non-Android when auto',
      () {
        final result = VideoPlayerState.resolveVideoEngine(
          engine: VideoPlayerEngine.auto,
          url: kTestWebmUrl,
        );

        expect(result, VideoPlayerEngine.videoPlayerPlugin);
      },
    );

    test('should return videoPlayerPlugin for non-.webm files when auto', () {
      final result = VideoPlayerState.resolveVideoEngine(
        engine: VideoPlayerEngine.auto,
        url: kTestMp4Url,
        isAndroid:
            true, // Even on Android, non-webm files use videoPlayerPlugin
      );

      expect(result, VideoPlayerEngine.videoPlayerPlugin);
    });

    test('should return the same engine when explicitly set', () {
      final result = VideoPlayerState.resolveVideoEngine(
        engine: VideoPlayerEngine.mpv,
        url: kTestWebmUrl,
        isAndroid: true,
      );

      expect(result, VideoPlayerEngine.mpv);
    });

    test('should handle null engine as auto', () {
      final result = VideoPlayerState.resolveVideoEngine(
        engine: null,
        url: kTestMp4Url,
      );

      expect(result, VideoPlayerEngine.videoPlayerPlugin);
    });
  });

  group('VideoPlayerState.fromPlayerState', () {
    late MockBooruPlayer mockPlayer;

    setUp(() {
      mockPlayer = MockBooruPlayer();
      when(() => mockPlayer.aspectRatio).thenReturn(16.0 / 9.0);
      when(() => mockPlayer.isPlatformSupported()).thenReturn(true);
    });

    test('should return ready state when initialized with player', () {
      final state = VideoPlayerState.fromPlayerState(
        player: mockPlayer,
        error: null,
        thumbnailUrl: kTestThumbnailUrl,
        isBuffering: false,
        aspectRatio: null,
      );

      expect(state, isA<VideoPlayerReady>());
    });

    test(
      'should return loading with thumbnail when initialized but no player and has thumbnail',
      () {
        final state = VideoPlayerState.fromPlayerState(
          player: null,
          error: null,
          thumbnailUrl: kTestThumbnailUrl,
          isBuffering: false,
          aspectRatio: 4.0 / 3.0,
        );

        expect(state, isA<VideoPlayerLoadingWithThumbnail>());
      },
    );

    test(
      'should return loading state when initialized but no player and no thumbnail',
      () {
        final state = VideoPlayerState.fromPlayerState(
          player: null,
          error: null,
          thumbnailUrl: null,
          isBuffering: false,
          aspectRatio: null,
        );

        expect(state, isA<VideoPlayerLoading>());
      },
    );

    test(
      'should return unsupported state when player platform not supported',
      () {
        when(() => mockPlayer.isPlatformSupported()).thenReturn(false);

        final state = VideoPlayerState.fromPlayerState(
          player: mockPlayer,
          error: null,
          thumbnailUrl: null,
          isBuffering: false,
          aspectRatio: null,
        );

        expect(state, isA<VideoPlayerUnsupported>());
      },
    );

    test('should return error state when error is present', () {
      final state = VideoPlayerState.fromPlayerState(
        player: null,
        error: 'Network error',
        thumbnailUrl: kTestThumbnailUrl,
        isBuffering: false,
        aspectRatio: null,
      );

      expect(state, isA<VideoPlayerError>());
    });

    test(
      'should return loading with thumbnail when not initialized but has thumbnail',
      () {
        final state = VideoPlayerState.fromPlayerState(
          player: null,
          error: null,
          thumbnailUrl: kTestThumbnailUrl,
          isBuffering: false,
          aspectRatio: 21.0 / 9.0,
        );

        expect(state, isA<VideoPlayerLoadingWithThumbnail>());
      },
    );

    test(
      'should return loading state when not initialized and no thumbnail',
      () {
        final state = VideoPlayerState.fromPlayerState(
          player: null,
          error: null,
          thumbnailUrl: null,
          isBuffering: false,
          aspectRatio: null,
        );

        expect(state, isA<VideoPlayerLoading>());
      },
    );

    test('should prioritize platform support check over error state', () {
      when(() => mockPlayer.isPlatformSupported()).thenReturn(false);

      final state = VideoPlayerState.fromPlayerState(
        player: mockPlayer,
        error: 'Critical error',
        thumbnailUrl: null,
        isBuffering: false,
        aspectRatio: null,
      );

      // Platform support check happens before error check
      expect(state, isA<VideoPlayerUnsupported>());
    });
  });
}
