// Dart imports:
import 'dart:math';

extension StringX on String {
  String getFirstCharacter() => this == '' ? '' : this[0];
  String getLastCharacter() => this == '' ? '' : this[length - 1];
  String replaceCharAt(int index, String newChar) =>
      substring(0, index) + newChar + substring(index + 1);

  String replaceAtIndexWhen({
    required bool Function(String value) condition,
    required int Function(String value) indexSelector,
    required String newChar,
  }) {
    if (condition(this)) {
      return replaceCharAt(indexSelector(this), newChar);
    }

    return this;
  }

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

  String replaceUnderscoreWithSpace() => replaceAll('_', ' ');

  ///
  /// Add a [char] at a [position] with the given String [s].
  ///
  /// The boolean [repeat] defines whether to add the [char] at every [position].
  /// If [position] is greater than the length of [s], it will return [s].
  /// If [repeat] is true and [position] is 0, it will return [s].
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

extension StringNullX on String? {
  bool isBlank() {
    if (this == null) return true;

    return this!.trim().isEmpty;
  }

  bool isNotBlank() => !isBlank();

  Set<String> splitByWhitespace() {
    if (this == null) return {};
    if (this!.isEmpty) return {};

    return this!.split(' ').toSet();
  }
}

String generateRandomWord(final int minLength, final int maxLength) {
  final rand = Random();
  final length = rand.nextInt(maxLength - minLength) + minLength;
  final aCode = 'a'.codeUnitAt(0);
  final zCode = 'z'.codeUnitAt(0);

  return String.fromCharCodes([
    for (var i = 0; i < length; i++) rand.nextInt(zCode - aCode + 1) + aCode,
  ]);
}
