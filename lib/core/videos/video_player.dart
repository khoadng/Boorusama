// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// Project imports:
import '../../foundation/utils/duration_utils.dart';
import '../configs/config/providers.dart';
import '../images/booru_image.dart';
import '../settings/src/providers/settings_provider.dart';
import '../widgets/widgets.dart';

//TODO: implement caching video
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
    this.onTap,
  });

  final String url;
  final double? aspectRatio;
  final void Function(double current, double total, String url)?
      onCurrentPositionChanged;
  final void Function(Player player)? onVideoPlayerCreated;
  final bool sound;
  final double speed;
  final String? thumbnailUrl;
  final void Function()? onOpenSettings;
  final Map<String, String>? headers;
  final String? heroTag;
  final void Function(bool value)? onInitializing;
  final VoidCallback? onTap;

  @override
  ConsumerState<BooruVideo> createState() => _BooruVideoState();
}

class _BooruVideoState extends ConsumerState<BooruVideo> {
  late final Player _player;
  late final VideoController _videoController;
  bool? _initialized;
  String? _error;
  bool _previouslyReportedInitializing = false;
  Timer? _timer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  bool _isBuffering = false;
  bool _hasPlayedOnce = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Map<String, String> _buildHeaders() => {
        if (widget.headers != null) ...widget.headers!,
      };

  void _initVideoPlayer() {
    final settings = ref.read(settingsProvider);
    final enableHardwareDecoding = settings.mediaKitHardwareDecoding;
    
    _player = Player();
    _videoController = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: enableHardwareDecoding,
      ),
    );

    widget.onVideoPlayerCreated?.call(_player);

    // Set initial volume and playback speed
    _player.setVolume(widget.sound ? 100.0 : 0.0);
    _player.setRate(widget.speed);

    _timer = Timer(
      const Duration(milliseconds: 1000),
      () {
        // If the video is still initializing, report back to the parent widget
        if (!_player.state.playing && !_initialized!) {
          widget.onInitializing?.call(true);
          _previouslyReportedInitializing = true;
        }
      },
    );

    _initialized = false;

    // Create media with headers
    final media = Media(
      widget.url,
      httpHeaders: _buildHeaders(),
    );

    // Open the media and handle initialization
    _player.open(media, play: false).then((_) {
      if (mounted) {
        setState(() {});
        _initialized = true;
        _clearInitializing();
        // Set looping back to single for individual media files
        _player.setPlaylistMode(PlaylistMode.single);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    });

    _listenToVideoPosition();
    _listenToBufferingState();
  }

  void _listenToBufferingState() {
    // Listen to buffering state
    _bufferingSubscription = _player.stream.buffering.listen((buffering) {
      if (mounted) {
        // Show buffering during initial load and genuine network buffering
        // But suppress it briefly during loop transitions
        if (buffering) {
          // If we haven't played once yet, always show buffering (initial load)
          if (!_hasPlayedOnce) {
            setState(() {
              _isBuffering = true;
            });
          } else {
            // For subsequent buffering, check if it's a genuine network issue
            // by adding a small delay to filter out loop-related buffering
            Timer(const Duration(milliseconds: 200), () {
              if (mounted && _player.state.buffering) {
                setState(() {
                  _isBuffering = true;
                });
              }
            });
          }
        } else {
          // Not buffering, hide indicator
          setState(() {
            _isBuffering = false;
          });
        }
      }
    });

    // Listen to playing state to detect when video has started playing
    _player.stream.playing.listen((playing) {
      if (mounted && playing && !_hasPlayedOnce) {
        _hasPlayedOnce = true;
      }
    });
  }

  void _clearInitializing() {
    if (_previouslyReportedInitializing) {
      widget.onInitializing?.call(false);
      _previouslyReportedInitializing = false;
    }

    _timer?.cancel();
    _timer = null;
  }

  void _disposeVideoPlayer() {
    _clearInitializing();
    _positionSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _initialized = null;
    _error = null;
    _player.dispose();
  }

  // Listen to the video position and report it back to the parent widget
  // if the callback is set.
  void _listenToVideoPosition() {
    if (widget.onCurrentPositionChanged != null) {
      _positionSubscription = _player.stream.position.listen((position) {
        final current = position.inPreciseSeconds;
        final total = _player.state.duration.inPreciseSeconds;
        widget.onCurrentPositionChanged!(current, total, widget.url);
      });
    }
  }

  @override
  void didUpdateWidget(BooruVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url || widget.headers != oldWidget.headers) {
      _disposeVideoPlayer();
      _initVideoPlayer();
    }

    if (widget.sound != oldWidget.sound) {
      _player.setVolume(widget.sound ? 100.0 : 0.0);
    }

    if (widget.speed != oldWidget.speed) {
      _player.setRate(widget.speed);
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.thumbnailUrl;

    return Center(
      child: _initialized == true
          ? AspectRatio(
              aspectRatio: widget.aspectRatio ??
                  ((_player.state.width ?? 0) > 0 && (_player.state.height ?? 0) > 0
                      ? (_player.state.width ?? 1) / (_player.state.height ?? 1)
                      : 16.0 / 9.0),
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
                            aspectRatio: widget.aspectRatio ??
                                ((_player.state.width ?? 0) > 0 && (_player.state.height ?? 0) > 0
                                    ? (_player.state.width ?? 1) / (_player.state.height ?? 1)
                                    : 16.0 / 9.0),
                            imageUrl: thumb,
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: widget.onTap,
                        child: Video(
                          controller: _videoController,
                          controls: NoVideoControls,
                        ),
                      ),
                    ),
                    // Show buffering indicator when buffering
                    if (_isBuffering)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Buffering...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
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
