extension ObjectX on Object? {
  double? toDoubleOrNull() {
    if (this == null) {
      return null;
    } else if (this is int) {
      return (this as int).toDouble();
    } else if (this is double) {
      return (this as double).isNaN ? null : this as double;
    } else if (this is String) {
      return double.tryParse(this as String);
    }
    return null;
  }
}
