// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/platform.dart';
import '../../../configs/config/providers.dart';
import '../../../images/booru_image.dart';
import '../../../settings/settings.dart';
import '../../../widgets/widgets.dart';
import '../providers/video_player_booru_player.dart';
import '../providers/webview_booru_player.dart';
import '../types/booru_player.dart';

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
    this.onInitializing,
    this.userAgent,
    this.videoPlayerEngine,
    this.logger,
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
  final ValueChanged<bool>? onInitializing;
  final String? userAgent;
  final VideoPlayerEngine? videoPlayerEngine;
  final Logger? logger;

  @override
  ConsumerState<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends ConsumerState<BooruVideo> {
  BooruPlayer? _player;
  bool _initialized = false;
  String? _error;
  bool _previouslyReportedInitializing = false;
  Timer? _timer;
  StreamSubscription<Duration>? _positionSubscription;

  bool get _shouldUseWebView => switch (widget.videoPlayerEngine ??
      VideoPlayerEngine.auto) {
    VideoPlayerEngine.videoPlayerPlugin || VideoPlayerEngine.mdk => false,
    VideoPlayerEngine.webview => true,
    VideoPlayerEngine.auto => extension(widget.url) == '.webm' && isAndroid(),
  };

  @override
  void initState() {
    super.initState();
    widget.logger?.debug(
      'UnifiedBooruVideo',
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
      widget.logger?.verbose(
        'UnifiedBooruVideo',
        'Widget updated, reinitializing player. URL: ${widget.url}',
      );
      _disposePlayer();
      _initializePlayer();
    } else {
      widget.logger?.debug(
        'UnifiedBooruVideo',
        'Widget updated, updating player settings only',
      );
      _updatePlayerSettings();
    }
  }

  void _updatePlayerSettings() {
    if (_player == null) {
      widget.logger?.warn(
        'UnifiedBooruVideo',
        'Cannot update player settings: player is null',
      );
      return;
    }

    widget.logger?.debug(
      'UnifiedBooruVideo',
      'Updating player settings - Volume: ${widget.sound ? 1.0 : 0.0}, Speed: ${widget.speed}',
    );
    _player!.setVolume(widget.sound ? 1.0 : 0.0);
    _player!.setPlaybackSpeed(widget.speed);
  }

  Future<void> _initializePlayer() async {
    try {
      if (_shouldUseWebView) {
        widget.logger?.verbose(
          'UnifiedBooruVideo',
          'Creating WebViewBooruPlayer for URL: ${widget.url}',
        );
        _player = WebViewBooruPlayer(
          userAgent: widget.userAgent,
          backgroundColor: Colors.black,
        );
      } else {
        widget.logger?.verbose(
          'UnifiedBooruVideo',
          'Creating VideoPlayerBooruPlayer with engine: ${widget.videoPlayerEngine ?? VideoPlayerEngine.auto} for URL: ${widget.url}',
        );
        _player = VideoPlayerBooruPlayer(
          videoPlayerEngine: widget.videoPlayerEngine ?? VideoPlayerEngine.auto,
        );
      }

      widget.onVideoPlayerCreated?.call(_player!);

      _timer = Timer(
        const Duration(milliseconds: 1000),
        () {
          if (!_initialized) {
            widget.logger?.debug(
              'UnifiedBooruVideo',
              'Player initialization taking longer than 1 second, showing loading indicator',
            );
            widget.onInitializing?.call(true);
            _previouslyReportedInitializing = true;
          }
        },
      );

      widget.logger?.debug(
        'UnifiedBooruVideo',
        'Initializing player with URL: ${widget.url}',
      );
      await _player!.initialize(widget.url, headers: widget.headers);

      // Set initial player settings
      widget.logger?.debug(
        'UnifiedBooruVideo',
        'Setting initial player configuration - Volume: ${widget.sound ? 1.0 : 0.0}, Speed: ${widget.speed}, Looping: true',
      );
      await _player!.setVolume(widget.sound ? 1.0 : 0.0);
      await _player!.setPlaybackSpeed(widget.speed);
      await _player!.setLooping(true);

      // Listen to position changes
      widget.logger?.debug(
        'UnifiedBooruVideo',
        'Setting up position stream listener',
      );
      _positionSubscription = _player!.positionStream.listen((position) {
        if (widget.onCurrentPositionChanged != null) {
          final current = position.inMilliseconds / 1000.0;
          final total = _player!.duration.inMilliseconds / 1000.0;
          widget.onCurrentPositionChanged!(current, total, widget.url);
        }
      });

      if (mounted) {
        widget.logger?.verbose(
          'UnifiedBooruVideo',
          'Player successfully initialized for URL: ${widget.url}',
        );
        setState(() {
          _initialized = true;
        });
        _clearInitializing();
      }
    } catch (error) {
      widget.logger?.error(
        'UnifiedBooruVideo',
        'Failed to initialize player for URL: ${widget.url}. Error: $error',
      );
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
        _clearInitializing();
      }
    }
  }

  void _clearInitializing() {
    if (_previouslyReportedInitializing) {
      widget.logger?.debug('UnifiedBooruVideo', 'Clearing initializing state');
      widget.onInitializing?.call(false);
      _previouslyReportedInitializing = false;
    }

    _timer?.cancel();
    _timer = null;
  }

  void _disposePlayer() {
    widget.logger?.debug(
      'UnifiedBooruVideo',
      'Disposing player for URL: ${widget.url}',
    );
    _clearInitializing();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _player?.dispose();
    _player = null;
    _initialized = false;
    _error = null;
  }

  @override
  void dispose() {
    widget.logger?.debug(
      'UnifiedBooruVideo',
      'Disposing UnifiedBooruVideo widget',
    );
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.thumbnailUrl;

    return Center(
      child: _initialized && _player != null
          ? AspectRatio(
              aspectRatio: widget.aspectRatio ?? _player!.aspectRatio,
              child: BooruHero(
                tag: widget.heroTag,
                child: Stack(
                  children: [
                    if (thumb != null)
                      Positioned.fill(
                        child: Consumer(
                          builder: (_, ref, _) => BooruImage(
                            config: ref.watchConfigAuth,
                            borderRadius: BorderRadius.zero,
                            aspectRatio:
                                widget.aspectRatio ?? _player!.aspectRatio,
                            imageUrl: thumb,
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: _player!.buildPlayerWidget(context),
                    ),
                  ],
                ),
              ),
            )
          : _error != null
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'If this happens on a regular basis, consider using a different video player engine in the settings.'
                        .hc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (widget.onOpenSettings != null)
                    FilledButton(
                      onPressed: widget.onOpenSettings,
                      child: Text(
                        context.t.settings.open_app_settings,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : BooruHero(
              tag: widget.heroTag,
              child: thumb != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Consumer(
                            builder: (_, ref, _) => BooruImage(
                              config: ref.watchConfigAuth,
                              borderRadius: BorderRadius.zero,
                              aspectRatio: widget.aspectRatio ?? 16.0 / 9.0,
                              imageUrl: thumb,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
            ),
    );
  }
}
