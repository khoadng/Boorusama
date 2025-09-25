// Project imports:
import '../../../posts/post/post.dart';
import '../widgets/video_player.dart';

const _kDefaultDelaySeconds = 3;
const _kMinDelaySeconds = 2;
const _kMaxDelaySeconds = 8;
const _kWatchPercentThreshold = 0.25;

CacheDelayCallback createVideoCacheDelayCallback<T extends Post>(T post) =>
    (url, state) => _calculateDelay(post);

Duration _calculateDelay(Post post) {
  final durationSeconds = post.duration;
  final fileSizeBytes = post.fileSize;

  return switch ((durationSeconds, fileSizeBytes)) {
    (final d, _) when d > 0 => _delayFromDuration(d),
    (_, final s) when s > 0 => _delayFromFileSize(s),
    _ => const Duration(seconds: _kDefaultDelaySeconds),
  };
}

Duration _delayFromDuration(double durationSeconds) {
  final calculatedDelay = durationSeconds * _kWatchPercentThreshold;
  final clampedSeconds = _clamp(
    calculatedDelay,
    _kMinDelaySeconds.toDouble(),
    _kMaxDelaySeconds.toDouble(),
  ).toInt();

  return Duration(seconds: clampedSeconds);
}

Duration _delayFromFileSize(int bytes) {
  final sizeMB = bytes / (1024 * 1024);
  final calculatedDelay = _kMinDelaySeconds + (sizeMB / 5);
  final clampedSeconds = _clamp(
    calculatedDelay,
    _kMinDelaySeconds.toDouble(),
    (_kMaxDelaySeconds - 1).toDouble(),
  ).toInt();

  return Duration(seconds: clampedSeconds);
}

double _clamp(double value, double min, double max) =>
    value < min ? min : (value > max ? max : value);
