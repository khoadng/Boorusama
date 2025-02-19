const _kEpsilon = 1e-6;

extension DoubleEx on double {
  bool isApproximatelyEqual(
    double other, {
    double? epsilon,
  }) {
    final effectiveEpsilon = epsilon ?? _kEpsilon;

    return (this - other).abs() < effectiveEpsilon;
  }
}
