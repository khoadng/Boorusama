// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/platform.dart';
import '../../../configs/config/providers.dart';
import '../../../images/booru_image.dart';
import '../../../settings/settings.dart';
import '../../../widgets/widgets.dart';
import '../providers/media_kit_booru_player.dart';
import '../providers/video_player_booru_player.dart';
import '../providers/webview_booru_player.dart';
import '../types/booru_player.dart';
import '../types/video_player_state.dart';
import 'video_player_error_container.dart';

class BooruVideo extends ConsumerStatefulWidget {
  const BooruVideo({
    required this.url,
    required this.aspectRatio,
    super.key,
    this.onCurrentPositionChanged,
    this.onVideoPlayerCreated,
    this.sound = true,
    this.speed = 1.0,
    this.thumbnailUrl,
    this.onOpenSettings,
    this.headers,
    this.heroTag,
    this.userAgent,
    this.videoPlayerEngine,
    this.logger,
    this.autoplay = false,
  });

  final String url;
  final double? aspectRatio;
  final PositionCallback? onCurrentPositionChanged;
  final VideoPlayerCreatedCallback? onVideoPlayerCreated;
  final bool sound;
  final double speed;
  final String? thumbnailUrl;
  final VoidCallback? onOpenSettings;
  final Map<String, String>? headers;
  final String? heroTag;
  final String? userAgent;
  final VideoPlayerEngine? videoPlayerEngine;
  final Logger? logger;
  final bool autoplay;

  @override
  ConsumerState<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends ConsumerState<BooruVideo> {
  BooruPlayer? _player;
  String? _error;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  bool _isBuffering = false;
  bool _isDisposing = false;

  VideoPlayerEngine get _resolvedEngine => VideoPlayerState.resolveVideoEngine(
    engine: widget.videoPlayerEngine,
    url: widget.url,
    isAndroid: isAndroid(),
  );

  VideoPlayerState get _currentState => VideoPlayerState.fromPlayerState(
    player: _player,
    error: _error,
    thumbnailUrl: widget.thumbnailUrl,
    isBuffering: _isBuffering,
    aspectRatio: widget.aspectRatio,
  );

  void _log(
    void Function(String tag, String message)? logMethod,
    String message,
  ) => logMethod?.call('VideoPlayer', message);

  bool _shouldAutoplay() {
    return mounted && !_isDisposing;
  }

  @override
  void initState() {
    super.initState();
    _log(
      widget.logger?.debug,
      'Initializing video player for URL: ${widget.url}',
    );
    _initializePlayer();
  }

  @override
  void didUpdateWidget(BooruVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url ||
        widget.headers != oldWidget.headers ||
        widget.videoPlayerEngine != oldWidget.videoPlayerEngine) {
      _log(
        widget.logger?.verbose,
        'Widget updated, reinitializing player. URL: ${widget.url}',
      );

      // Reset disposing flag for new initialization
      _isDisposing = false;
      _error = null;

      _initializePlayer();
    } else {
      _log(
        widget.logger?.debug,
        'Widget updated, updating player settings only',
      );
      _updatePlayerSettings();
    }
  }

  void _updatePlayerSettings() {
    if (_player == null) {
      _log(
        widget.logger?.warn,
        'Cannot update player settings: player is null',
      );
      return;
    }

    _log(
      widget.logger?.debug,
      'Updating player settings - Volume: ${widget.sound ? 1.0 : 0.0}, Speed: ${widget.speed}',
    );
    if (_player case final player?) {
      player
        ..setVolume(widget.sound ? 1.0 : 0.0)
        ..setPlaybackSpeed(widget.speed);
    }
  }

  Future<void> _initializePlayer() async {
    if (!mounted || _isDisposing) return;

    try {
      _log(
        widget.logger?.debug,
        'Initializing $_resolvedEngine player for ${widget.url}',
      );

      // If we already have a player, try fast URL switching first
      if (_player != null && !_isDisposing) {
        _log(
          widget.logger?.debug,
          'Using fast URL switching',
        );

        try {
          if (_player case final player?) {
            await player.switchUrl(
              widget.url,
              config: VideoConfig(
                headers: widget.headers,
                autoplay: widget.autoplay && _shouldAutoplay(),
              ),
            );
          } else {
            return;
          }

          _updatePlayerSettings();

          if (mounted && !_isDisposing) {
            setState(() {});
            if (_player case final player?) {
              widget.onVideoPlayerCreated?.call(player);
            }
          }

          _log(
            widget.logger?.verbose,
            'Fast URL switching successful for: ${widget.url}',
          );
          return;
        } catch (error) {
          _log(
            widget.logger?.warn,
            'Fast URL switching failed for ${widget.url}, falling back to full initialization. Error: $error',
          );
          // Fall through to full initialization
        }
      }

      // First initialization or no existing player, create new one
      final oldPlayer = _player;
      final player = switch (_resolvedEngine) {
        VideoPlayerEngine.webview => WebViewBooruPlayer(
          userAgent: widget.userAgent,
          backgroundColor: Colors.black,
        ),
        VideoPlayerEngine.mpv => MediaKitBooruPlayer(),
        VideoPlayerEngine.auto ||
        VideoPlayerEngine.videoPlayerPlugin ||
        VideoPlayerEngine.mdk => VideoPlayerBooruPlayer(
          videoPlayerEngine: _resolvedEngine,
        ),
      };

      if (!player.isPlatformSupported()) {
        return;
      }

      _log(
        widget.logger?.debug,
        'Initializing new player with URL: ${widget.url}',
      );

      await player.initialize(
        widget.url,
        config: VideoConfig(
          headers: widget.headers,
          autoplay: widget.autoplay && _shouldAutoplay(),
        ),
      );

      _log(
        widget.logger?.debug,
        'Setting initial player configuration - Volume: ${widget.sound ? 1.0 : 0.0}, Speed: ${widget.speed}, Looping: true',
      );
      await player.setVolume(widget.sound ? 1.0 : 0.0);
      await player.setPlaybackSpeed(widget.speed);
      await player.setLooping(true);

      if (widget.autoplay && _shouldAutoplay()) {
        _log(
          widget.logger?.debug,
          'Starting autoplay for URL: ${widget.url}',
        );
        await player.play();
      }

      _log(
        widget.logger?.debug,
        'Setting up position stream listener',
      );
      _positionSubscription?.cancel().ignore();
      _positionSubscription = player.positionStream.listen((position) {
        if (widget.onCurrentPositionChanged != null) {
          final current = position.inMilliseconds / 1000.0;
          final total = player.duration.inMilliseconds / 1000.0;
          widget.onCurrentPositionChanged!(current, total, widget.url);
        }
      });

      _log(
        widget.logger?.debug,
        'Setting up buffering stream listener',
      );
      _bufferingSubscription?.cancel().ignore();
      _bufferingSubscription = player.bufferingStream.listen((buffering) {
        if (mounted) {
          setState(() {
            _isBuffering = buffering;
          });
        }
      });

      if (mounted && !_isDisposing) {
        _log(
          widget.logger?.verbose,
          'Player successfully initialized for URL: ${widget.url}',
        );

        _player = player;
        setState(() {});
        widget.onVideoPlayerCreated?.call(player);

        if (oldPlayer != null) {
          _disposePlayerSafely(oldPlayer);
        }
      } else {
        // Widget is disposing, clean up the newly created player
        _log(
          widget.logger?.debug,
          'Player initialized but widget is disposing, cleaning up',
        );
        player.dispose();
      }
    } catch (error) {
      _log(
        widget.logger?.error,
        'Failed to initialize player for URL: ${widget.url}. Error: $error',
      );
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _disposePlayer() async {
    if (_isDisposing) return;
    _isDisposing = true;

    _log(
      widget.logger?.debug,
      'Disposing player for URL: ${widget.url}',
    );

    // Cancel subscriptions first to stop audio callbacks
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _bufferingSubscription?.cancel();
    _bufferingSubscription = null;

    // Immediately mute and stop the player before disposal
    if (_player case final player?) {
      try {
        await player.setVolume(0);
        await player.pause();
      } catch (e) {
        _log(widget.logger?.warn, 'Error stopping player before disposal: $e');
      }

      player.dispose();
    }

    _player = null;
    _error = null;
    _isBuffering = false;
  }

  void _disposePlayerSafely(BooruPlayer player) {
    _log(
      widget.logger?.debug,
      'Safely disposing background player',
    );

    (() async {
      try {
        await player.setVolume(0);
        await player.pause();
        player.dispose();
      } catch (e) {
        _log(
          widget.logger?.warn,
          'Error during background player disposal: $e',
        );
      }
    })();
  }

  @override
  void dispose() {
    _log(
      widget.logger?.debug,
      'Disposing BooruVideo widget',
    );
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: switch (_currentState) {
        VideoPlayerReady(
          :final player,
          :final thumbnailUrl,
          :final isBuffering,
          :final aspectRatio,
        ) =>
          AspectRatio(
            aspectRatio: aspectRatio,
            child: BooruHero(
              tag: widget.heroTag,
              child: Stack(
                children: [
                  if (thumbnailUrl case final url?)
                    Positioned.fill(
                      child: Consumer(
                        builder: (_, ref, _) => BooruImage(
                          config: ref.watchConfigAuth,
                          borderRadius: BorderRadius.zero,
                          aspectRatio: aspectRatio,
                          imageUrl: url,
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: player.buildPlayerWidget(context),
                  ),
                  if (isBuffering)
                    _BufferingOverlay(
                      thumbnailUrl: thumbnailUrl,
                      aspectRatio: aspectRatio,
                    ),
                ],
              ),
            ),
          ),
        VideoPlayerUnsupported() => VideoPlayerErrorContainer(
          title: context.t.video_player.engine_not_supported,
          subtitle: context.t.video_player.change_video_player_engine_request,
          onOpenSettings: widget.onOpenSettings,
        ),
        VideoPlayerError(:final error) => VideoPlayerErrorContainer(
          title: error,
          subtitle: context.t.video_player.change_video_player_engine_suggest,
          onOpenSettings: widget.onOpenSettings,
        ),
        VideoPlayerLoadingWithThumbnail(
          :final thumbnailUrl,
          :final aspectRatio,
        ) =>
          BooruHero(
            tag: widget.heroTag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Consumer(
                    builder: (_, ref, _) => BooruImage(
                      config: ref.watchConfigAuth,
                      borderRadius: BorderRadius.zero,
                      aspectRatio: aspectRatio,
                      imageUrl: thumbnailUrl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        VideoPlayerLoading() => const BooruHero(
          tag: null,
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      },
    );
  }
}

class _BufferingOverlay extends StatelessWidget {
  const _BufferingOverlay({
    required this.thumbnailUrl,
    required this.aspectRatio,
  });

  final String? thumbnailUrl;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (thumbnailUrl case final thumb?)
            Consumer(
              builder: (_, ref, _) => BooruImage(
                config: ref.watchConfigAuth,
                borderRadius: BorderRadius.zero,
                aspectRatio: aspectRatio,
                imageUrl: thumb,
              ),
            ),
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t.video_player.buffering,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
