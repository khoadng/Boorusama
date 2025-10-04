// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../engines/types.dart';
import 'video_progress.dart';

class VideoPlaybackManager extends ChangeNotifier {
  VideoPlaybackManager();

  final Map<int, BooruPlayer> _players = {};
  final Set<int> _pendingPlayback = {};
  final _videoProgress = ValueNotifier(VideoProgress.zero);
  final _isVideoPlaying = ValueNotifier<bool>(false);
  final _seekStreamController = StreamController<VideoProgress>.broadcast();

  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;
  ValueNotifier<bool> get isVideoPlaying => _isVideoPlaying;
  Stream<VideoProgress> get seekStream => _seekStreamController.stream;

  void registerPlayer(BooruPlayer player, int id) {
    _players[id] = player;

    // If playback was requested before registration, play now
    if (_pendingPlayback.contains(id)) {
      _pendingPlayback.remove(id);
      unawaited(player.play());
    }
  }

  void unregisterPlayer(int id) {
    _players.remove(id);
    _pendingPlayback.remove(id);
  }

  Future<void> playVideo(int id) async {
    _isVideoPlaying.value = true;
    final player = _players[id];
    if (player != null) {
      unawaited(player.play());
    } else {
      // Player not registered yet, mark for pending playback
      _pendingPlayback.add(id);
    }
  }

  Future<void> pauseVideo(int id) async {
    _isVideoPlaying.value = false;
    final player = _players[id];
    if (player != null) {
      unawaited(player.pause());
    }
  }

  void seekVideo(Duration position, int id) {
    final player = _players[id];
    if (player != null) {
      player.seek(position);

      _seekStreamController.add(
        VideoProgress(
          position,
          _videoProgress.value.duration,
        ),
      );
    }
  }

  void updateProgress(
    double current,
    double total,
    int currentVideoId,
  ) {
    final currentPlayer = _players[currentVideoId];
    if (currentPlayer != null) {
      final progress = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()),
      );

      if (progress != _videoProgress.value) {
        _videoProgress.value = progress;
      }
    }
  }

  void resetProgress() {
    _videoProgress.value = VideoProgress.zero;
  }

  BooruPlayer? getPlayer(int id) {
    return _players[id];
  }

  Duration? seekVideoByDirection(
    int playerId,
    bool isForward,
    Duration? postDuration,
    int doubleTapSeekDurationSeconds,
  ) {
    final seekAmount = Duration(seconds: doubleTapSeekDurationSeconds);
    final progress = videoProgress.value;

    final seekPosition = isForward
        ? progress.seekForward(seekAmount)
        : progress.seekBackward(seekAmount);

    seekVideo(seekPosition, playerId);
    return seekPosition;
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _pendingPlayback.clear();

    _videoProgress.dispose();
    _isVideoPlaying.dispose();
    _seekStreamController.close();

    super.dispose();
  }
}
