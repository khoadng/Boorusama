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
}
