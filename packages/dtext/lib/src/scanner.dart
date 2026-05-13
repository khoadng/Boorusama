class SourceScanner {
  SourceScanner(String source)
    : source = source.replaceAll('\r\n', '\n').replaceAll('\u0000', '');

  final String source;
  var offset = 0;

  bool get isDone => offset >= source.length;

  bool get isAtLineStart => offset == 0 || source.codeUnitAt(offset - 1) == 10;

  String get rest => source.substring(offset);

  String? get current => isDone ? null : source[offset];

  bool startsWith(String value, {bool caseSensitive = true}) {
    if (offset + value.length > source.length) return false;

    final slice = source.substring(offset, offset + value.length);
    return caseSensitive
        ? slice == value
        : slice.toLowerCase() == value.toLowerCase();
  }

  bool startsWithAny(Iterable<String> values, {bool caseSensitive = true}) =>
      values.any((value) => startsWith(value, caseSensitive: caseSensitive));

  String? match(RegExp regex) {
    final result = regex.matchAsPrefix(rest);
    if (result == null) return null;

    return result.group(0);
  }

  Match? matchGroups(RegExp regex) => regex.matchAsPrefix(rest);

  String advance(int count) {
    final start = offset;
    offset += count;
    return source.substring(start, offset);
  }

  String advanceOne() => advance(1);

  bool consume(String value, {bool caseSensitive = true}) {
    if (!startsWith(value, caseSensitive: caseSensitive)) return false;

    advance(value.length);
    return true;
  }

  String readUntilNewline() {
    final start = offset;
    while (!isDone && current != '\n') {
      offset++;
    }
    return source.substring(start, offset);
  }

  String readUntil(String value, {bool caseSensitive = true}) {
    final haystack = caseSensitive ? source : source.toLowerCase();
    final needle = caseSensitive ? value : value.toLowerCase();
    final index = haystack.indexOf(needle, offset);
    if (index < 0) {
      final text = source.substring(offset);
      offset = source.length;
      return text;
    }

    final text = source.substring(offset, index);
    offset = index;
    return text;
  }

  String readUntilCloseTag(String name) {
    final lower = source.toLowerCase();
    final bracket = '[/${name.toLowerCase()}]';
    final angle = '</${name.toLowerCase()}>';
    final bracketIndex = lower.indexOf(bracket, offset);
    final angleIndex = lower.indexOf(angle, offset);
    final indexes = [bracketIndex, angleIndex].where((index) => index >= 0);
    if (indexes.isEmpty) {
      return readUntil('\u{0}');
    }

    final end = indexes.reduce((a, b) => a < b ? a : b);
    final text = source.substring(offset, end);
    offset = end;
    return text;
  }

  bool consumeNewline() => consume('\n');

  bool isBlankLineAtOffset() {
    var index = offset;
    while (index < source.length) {
      final char = source[index];
      if (char == '\n') return true;
      if (char != ' ' && char != '\t') return false;
      index++;
    }

    return true;
  }

  void consumeBlankLines() {
    while (!isDone && isBlankLineAtOffset()) {
      while (!isDone && current != '\n') {
        offset++;
      }
      consumeNewline();
    }
  }
}
