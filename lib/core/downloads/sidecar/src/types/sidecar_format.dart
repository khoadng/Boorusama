enum SidecarFormat {
  off,
  tags,
  json;

  static SidecarFormat parse(Object? value) => switch (value) {
    null || 'off' => off,
    'tags' => tags,
    'json' => json,
    _ => throw FormatException('Unknown sidecar format: $value'),
  };

  String get extension => switch (this) {
    off => throw StateError('Disabled sidecars have no extension'),
    tags => 'txt',
    json => 'json',
  };
}
