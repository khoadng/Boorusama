extension DoubleEx on double {
  int? toIntOrNull() {
    if (!isFinite) return null;

    return toInt();
  }
}
