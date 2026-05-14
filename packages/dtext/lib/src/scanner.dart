import 'characters.dart';

class SourceScanner {
  SourceScanner(String source)
    : source = source.replaceAll('\r\n', '\n').replaceAll('\u0000', '');

  final String source;
  var offset = 0;

  bool get isDone => offset >= source.length;

  bool get isAtLineStart =>
      offset == 0 || source.codeUnitAt(offset - 1) == lineFeedCode;

  String get rest => source.substring(offset);

  String? get current => isDone ? null : source[offset];

  bool startsWith(String value, {bool caseSensitive = true}) =>
      startsWithAt(offset, value, caseSensitive: caseSensitive);

  bool startsWithAt(
    int start,
    String value, {
    bool caseSensitive = true,
  }) {
    if (start + value.length > source.length) return false;

    for (var i = 0; i < value.length; i++) {
      final sourceUnit = source.codeUnitAt(start + i);
      final valueUnit = value.codeUnitAt(i);
      if (caseSensitive) {
        if (sourceUnit != valueUnit) return false;
      } else if (toAsciiLower(sourceUnit) != toAsciiLower(valueUnit)) {
        return false;
      }
    }

    return true;
  }

  bool startsWithAny(Iterable<String> values, {bool caseSensitive = true}) =>
      values.any((value) => startsWith(value, caseSensitive: caseSensitive));

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
    final index = indexOf(value, start: offset, caseSensitive: caseSensitive);
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
    final bracket = '[/${name.toLowerCase()}]';
    final angle = '</${name.toLowerCase()}>';
    final bracketIndex = indexOf(bracket, start: offset, caseSensitive: false);
    final angleIndex = indexOf(angle, start: offset, caseSensitive: false);
    final indexes = [bracketIndex, angleIndex].where((index) => index >= 0);
    if (indexes.isEmpty) {
      return readUntil('\u{0}');
    }

    final end = indexes.reduce((a, b) => a < b ? a : b);
    final text = source.substring(offset, end);
    offset = end;
    return text;
  }

  int indexOf(
    String value, {
    int? start,
    bool caseSensitive = true,
  }) {
    final from = start ?? offset;
    if (value.isEmpty) return from;
    final end = source.length - value.length;
    for (var i = from; i <= end; i++) {
      if (startsWithAt(i, value, caseSensitive: caseSensitive)) return i;
    }

    return -1;
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
