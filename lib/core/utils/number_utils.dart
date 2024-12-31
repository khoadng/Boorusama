extension DoubleEx on double {
  int? toIntOrNull() {
    if (!isFinite) return null;

    return toInt();
  }
}

extension NumberEx on String? {
  int? toIntOrNull() {
    if (this == null) return null;

    return int.tryParse(this!);
  }

  double? toDoubleOrNull() {
    if (this == null) return null;

    return double.tryParse(this!);
  }
}
