enum VideoAudioDefaultState {
  unspecified,
  unmute,
  mute;

  factory VideoAudioDefaultState.parse(dynamic value) => switch (value) {
    'unspecified' || '0' || 0 => unspecified,
    'unmute' || '1' || 1 => unmute,
    'mute' || '2' || 2 => mute,
    _ => defaultValue,
  };

  bool get muteByDefault => this == mute;

  static const VideoAudioDefaultState defaultValue = unspecified;

  dynamic toData() => index;
}
