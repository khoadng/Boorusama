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
  final _videoProgress = ValueNotifier(VideoProgress.zero);
  final _isVideoPlaying = ValueNotifier<bool>(false);
  final _seekStreamController = StreamController<VideoProgress>.broadcast();

  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;
  ValueNotifier<bool> get isVideoPlaying => _isVideoPlaying;
  Stream<VideoProgress> get seekStream => _seekStreamController.stream;

  void registerPlayer(BooruPlayer player, int id) {
    _players[id] = player;
  }

  void unregisterPlayer(int id) {
    _players[id]?.dispose();
    _players.remove(id);
  }

  Future<void> playVideo(int id) async {
    _isVideoPlaying.value = true;
    final player = _players[id];
    if (player != null) {
      unawaited(player.play());
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
    String url,
    int currentVideoId,
  ) {
    final currentPlayer = _players[currentVideoId];
    if (currentPlayer != null) {
      _videoProgress.value = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()),
      );
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

    _videoProgress.dispose();
    _isVideoPlaying.dispose();
    _seekStreamController.close();

    super.dispose();
  }
}
