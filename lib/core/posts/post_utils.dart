Set<String> splitRawTagString(String? rawTagString) {
  if (rawTagString == null) return {};
  if (rawTagString.isEmpty) return {};

  return rawTagString.split(' ').where((element) => element.isNotEmpty).toSet();
}

extension TagStringSplitter on String? {
  Set<String> splitTagString() => splitRawTagString(this);
}
