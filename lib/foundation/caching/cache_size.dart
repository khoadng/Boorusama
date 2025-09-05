// Package imports:
import 'package:equatable/equatable.dart';

// Minimum cache size is 5 MB.
const _kMinCacheSizeBytes = 5 * 1024 * 1024;

class CacheSize extends Equatable {
  const CacheSize._(this.bytes);

  static CacheSize? tryParse(dynamic value) => switch (value) {
    final String text when text.trim().isNotEmpty => _parseFromString(
      text.trim().toLowerCase(),
    ),
    final int number when number == -1 => CacheSize._(number),
    final int number when number >= _kMinCacheSizeBytes => CacheSize._(number),
    _ => null,
  };

  static CacheSize? _parseFromString(String normalized) {
    if (normalized == 'unlimited') return CacheSize.unlimited;

    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(b|kb|mb|gb)$');
    return switch (regex.firstMatch(normalized)) {
      final RegExpMatch match => switch ((
        double.tryParse(match.group(1)!),
        match.group(2)!,
      )) {
        (final number?, final unit) when number >= 0 => switch (unit) {
          'b' => CacheSize._(number.round()),
          'kb' => CacheSize._((number * 1024).round()),
          'mb' => CacheSize._((number * 1024 * 1024).round()),
          'gb' => CacheSize._((number * 1024 * 1024 * 1024).round()),
          _ => null,
        },
        _ => null,
      },
      _ => null,
    };
  }

  static const zero = CacheSize._(0);
  static const unlimited = CacheSize._(-1);
  static const oneHundredMegabytes = CacheSize._(100 * 1024 * 1024);
  static const fiveHundredMegabytes = CacheSize._(500 * 1024 * 1024);
  static const oneGigabyte = CacheSize._(1024 * 1024 * 1024);
  static const twoGigabytes = CacheSize._(2 * 1024 * 1024 * 1024);
  static const fiveGigabytes = CacheSize._(5 * 1024 * 1024 * 1024);
  static const tenGigabytes = CacheSize._(10 * 1024 * 1024 * 1024);

  final int bytes;

  bool get isZero => bytes == 0;
  bool get isUnlimited => bytes == -1;

  String displayString({bool withSpace = false}) => switch (bytes) {
    -1 => 'unlimited',
    < 1024 => '$bytes${withSpace ? ' ' : ''}B',
    < 1024 * 1024 => _formatUnit(bytes / 1024, 'KB', withSpace),
    < 1024 * 1024 * 1024 => _formatUnit(bytes / (1024 * 1024), 'MB', withSpace),
    _ => _formatUnit(bytes / (1024 * 1024 * 1024), 'GB', withSpace),
  };

  String _formatUnit(double value, String unit, bool withSpace) {
    final separator = withSpace ? ' ' : '';
    return switch (value) {
      final double v when v == v.truncate() => '${v.truncate()}$separator$unit',
      final double v => '${v.toStringAsFixed(1)}$separator$unit',
    };
  }

  @override
  String toString() => displayString();

  @override
  List<Object> get props => [bytes];
}
