final class KeyPath {
  KeyPath._(this.segments);

  factory KeyPath.fromSegments(Iterable<String> segments) {
    final list = List<String>.unmodifiable(segments);
    if (list.isEmpty) {
      throw const FormatException('Key path must not be empty.');
    }
    if (list.any((segment) => segment.isEmpty)) {
      throw const FormatException('Key path segments must not be empty.');
    }

    return KeyPath._(list);
  }

  factory KeyPath.parse(String source) {
    if (source.trim().isEmpty) {
      throw const FormatException('Key path must not be empty.');
    }

    final segments = <String>[];
    final buffer = StringBuffer();
    var escaping = false;

    for (final codeUnit in source.codeUnits) {
      final char = String.fromCharCode(codeUnit);

      if (escaping) {
        buffer.write(char);
        escaping = false;
        continue;
      }

      if (char == r'\') {
        escaping = true;
        continue;
      }

      if (char == '.') {
        if (buffer.isEmpty) {
          throw FormatException('Invalid empty segment in key path "$source".');
        }
        segments.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    if (escaping) {
      throw FormatException('Invalid trailing escape in key path "$source".');
    }

    if (buffer.isEmpty) {
      throw FormatException('Invalid empty segment in key path "$source".');
    }

    segments.add(buffer.toString());

    return KeyPath._(List.unmodifiable(segments));
  }

  final List<String> segments;

  String get leaf => segments.last;

  KeyPath? get parent {
    if (segments.length == 1) return null;

    return KeyPath._(List.unmodifiable(segments.take(segments.length - 1)));
  }

  KeyPath child(KeyPath child) => KeyPath.fromSegments([
    ...segments,
    ...child.segments,
  ]);

  bool startsWith(KeyPath other) {
    if (other.segments.length > segments.length) return false;

    for (var i = 0; i < other.segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }

    return true;
  }

  @override
  String toString() => segments.map(_escapeSegment).join('.');

  static String _escapeSegment(String segment) =>
      segment.replaceAll(r'\', r'\\').replaceAll('.', r'\.');
}
