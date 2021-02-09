class TagString {
  final String _value;

  TagString(this._value);

  String toCommaFormat() {
    return _value.replaceAll(" ", ",");
  }

  String get value => _value;

  bool contains(String tag) => value.split(" ").contains(tag);

  @override
  String toString() => _value;
}
