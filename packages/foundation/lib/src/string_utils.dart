// Dart imports:
import 'dart:math';

extension StringX on String {
  String get sentenceCase => _getSentenceCase(this);
  String get pascalCase => _getPascalCase(this);
  String get titleCase => _getPascalCase(this, separator: ' ');

  String getFirstCharacter() => this == '' ? '' : this[0];
  String getLastCharacter() => this == '' ? '' : this[length - 1];

  String pipe(
    List<String Function(String text)> funcs,
  ) {
    var t = this;
    for (final f in funcs) {
      t = f(t);
    }

    return t;
  }

  int? toInt() => int.tryParse(this);
  bool? toBool() => bool.tryParse(this);

  ///
  /// Add a [char] at a [position] with the given string.
  ///
  /// The boolean [repeat] defines whether to add the [char] at every [position].
  /// If [position] is greater than the length of the string, it will return the original string.
  /// If [repeat] is true and [position] is 0, it will return the original string.
  ///
  /// Example :
  /// 1234567890 , '-', 3 => 123-4567890
  /// 1234567890 , '-', 3, true => 123-456-789-0
  ///
  String addCharAtPosition(
    String char,
    int position, {
    bool repeat = false,
  }) {
    if (!repeat) {
      if (length < position) return this;

      final before = substring(0, position);
      final after = substring(position, length);
      return before + char + after;
    } else {
      if (position == 0) return this;

      final buffer = StringBuffer();
      for (var i = 0; i < length; i++) {
        if (i != 0 && i % position == 0) {
          buffer.write(char);
        }
        buffer.write(String.fromCharCode(runes.elementAt(i)));
      }
      return buffer.toString();
    }
  }
}

String _getSentenceCase(String text, {String separator = ' '}) {
  // ignore: no_leading_underscores_for_local_identifiers
  final _words = _groupIntoWords(text);

  final words = _words.map((word) => word.toLowerCase()).toList();
  if (_words.isNotEmpty) {
    words[0] = _upperCaseFirstLetter(words[0]);
  }

  return words.join(separator);
}

String _getPascalCase(String text, {String separator = ''}) {
  // ignore: no_leading_underscores_for_local_identifiers
  final _words = _groupIntoWords(text);

  final words = _words.map(_upperCaseFirstLetter).toList();

  return words.join(separator);
}

String _upperCaseFirstLetter(String word) {
  return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
}

List<String> _groupIntoWords(String text) {
  final sb = StringBuffer();
  final words = <String>[];
  final isAllCaps = text.toUpperCase() == text;

  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    final nextChar = i + 1 == text.length ? null : text[i + 1];

    if (_symbolSet.contains(char)) {
      continue;
    }

    sb.write(char);

    final isEndOfWord =
        nextChar == null ||
        (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
        _symbolSet.contains(nextChar);

    if (isEndOfWord) {
      words.add(sb.toString());
      sb.clear();
    }
  }

  return words;
}

final RegExp _upperAlphaRegex = RegExp('[A-Z]');

const _symbolSet = {' ', '.', '/', '_', r'\', '-'};

String generateRandomWord(final int minLength, final int maxLength) {
  final rand = Random();
  final length = rand.nextInt(maxLength - minLength) + minLength;
  final aCode = 'a'.codeUnitAt(0);
  final zCode = 'z'.codeUnitAt(0);

  return String.fromCharCodes([
    for (var i = 0; i < length; i++) rand.nextInt(zCode - aCode + 1) + aCode,
  ]);
}
