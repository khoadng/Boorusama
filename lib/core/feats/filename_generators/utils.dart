extension CollectionX<T> on Iterable<T?> {
  Iterable<T> whereNotNull() =>
      where((element) => element != null).map((e) => e!);
}

extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  double? toDoubleCommaAware() {
    final index = indexOf(',');
    if (index != -1) {
      return double.tryParse(replaceAll(',', '.'));
    }
    return double.tryParse(this);
  }
}

List<String> cleanAndRemoveDuplicates(List<String> input) {
  List<String> cleaned = [];

  for (String str in input) {
    int index = str.indexOf('_(');
    if (index != -1) {
      str = str.substring(0, index);
    }
    if (!cleaned.contains(str)) {
      cleaned.add(str);
    }
  }

  return cleaned;
}
