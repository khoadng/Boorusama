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
}

extension StringNullX on String? {
  bool isNotNullAndEmpty() => this != null && this != '';
  List<String> splitByWhitespace() {
    if (this == null) return [];
    if (this!.isEmpty) return [];

    return this!.split(' ');
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
