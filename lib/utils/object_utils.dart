extension ObjectX on Object? {
  double? toDoubleOrNull() {
    if (this == null) {
      return null;
    } else if (this is double || this is int) {
      return (this as num).toDouble();
    } else if (this is String) {
      return double.tryParse(this as String);
    }
    return null;
  }
}
