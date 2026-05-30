enum BuildReleaseChannel {
  unknown,
  github,
  play,
}

extension BuildReleaseChannelX on BuildReleaseChannel {
  String get wireName => switch (this) {
    BuildReleaseChannel.unknown => 'unknown',
    BuildReleaseChannel.github => 'github',
    BuildReleaseChannel.play => 'play',
  };

  static BuildReleaseChannel? parse(String value) {
    final normalizedValue = value.trim().toLowerCase();
    for (final channel in BuildReleaseChannel.values) {
      if (channel.wireName == normalizedValue) return channel;
    }
    return null;
  }
}
