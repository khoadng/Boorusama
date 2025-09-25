// Package imports:
import 'package:equatable/equatable.dart';

class VideoProgress extends Equatable {
  const VideoProgress(
    this.duration,
    this.position,
  );

  final Duration duration;
  final Duration position;

  static const zero = VideoProgress(Duration.zero, Duration.zero);

  Duration seekForward(Duration amount) => _clamp(position + amount);

  Duration seekBackward(Duration amount) => _clamp(position - amount);

  Duration _clamp(Duration pos) => Duration(
    milliseconds: pos.inMilliseconds.clamp(
      0,
      duration.inMilliseconds,
    ),
  );

  @override
  List<Object?> get props => [duration, position];
}
