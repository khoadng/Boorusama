// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../foundation/caching/types.dart';

const _kDefaultDelaySeconds = 3;
const _kMinDelaySeconds = 2;
const _kMaxDelaySeconds = 8;
const _kWatchPercentThreshold = 0.25;

class VideoCacheLimitOptions {
  const VideoCacheLimitOptions._();

  static const minCustomGigabytes = 5;
  static const maxCustomGigabytes = 200;
  static const customStepGigabytes = 10;
  static const defaultCustomGigabytes = 50;

  static const presets = [
    CacheSize.oneHundredMegabytes,
    CacheSize.fiveHundredMegabytes,
    CacheSize.oneGigabyte,
    CacheSize.twoGigabytes,
    CacheSize.fiveGigabytes,
    CacheSize.tenGigabytes,
    CacheSize.zero,
  ];

  static List<VideoCacheLimitOption> dropdownOptions() {
    return [
      ...presets.map(VideoCacheLimitOption.size),
      VideoCacheLimitOption.custom(),
    ];
  }

  static VideoCacheLimitOption selectedOption(CacheSize currentValue) {
    return presets.contains(currentValue)
        ? VideoCacheLimitOption.size(currentValue)
        : VideoCacheLimitOption.custom();
  }

  static int initialCustomGigabytes(CacheSize currentValue) {
    if (currentValue.isZero) return defaultCustomGigabytes;

    return snapGigabytes(
      (currentValue.bytes / bytesPerGigabyte).round(),
    );
  }

  static CacheSize fromGigabytes(int gigabytes) {
    final clamped = snapGigabytes(gigabytes);

    return CacheSize.tryParse(clamped * bytesPerGigabyte)!;
  }

  static bool canDecrease(int gigabytes) => gigabytes > minCustomGigabytes;

  static bool canIncrease(int gigabytes) => gigabytes < maxCustomGigabytes;

  static int decrease(int gigabytes) {
    return snapGigabytes(gigabytes - customStepGigabytes);
  }

  static int increase(int gigabytes) {
    return snapGigabytes(gigabytes + customStepGigabytes);
  }

  static int snapGigabytes(int gigabytes) {
    final clamped = gigabytes.clamp(minCustomGigabytes, maxCustomGigabytes);

    return (clamped / customStepGigabytes).round() * customStepGigabytes;
  }

  static const bytesPerGigabyte = 1024 * 1024 * 1024;
}

class VideoCacheLimitOption extends Equatable {
  const VideoCacheLimitOption._({
    required this.cacheSize,
    required this.isCustom,
  });

  factory VideoCacheLimitOption.size(CacheSize cacheSize) =>
      VideoCacheLimitOption._(
        cacheSize: cacheSize,
        isCustom: false,
      );

  factory VideoCacheLimitOption.custom() => const VideoCacheLimitOption._(
    cacheSize: null,
    isCustom: true,
  );

  final CacheSize? cacheSize;
  final bool isCustom;

  @override
  List<Object?> get props => [cacheSize, isCustom];
}

Duration calculateCacheDelay(double durationSeconds, int fileSizeBytes) {
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
