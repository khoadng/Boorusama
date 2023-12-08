// Dart imports:
import 'dart:math';

class StatisticalSummary {
  final double mean;
  final double median;
  final double highest;
  final double lowest;
  final double standardDeviation;

  final double percentile25;
  final double percentile75;
  final double percentile90;

  StatisticalSummary({
    required this.mean,
    required this.median,
    required this.highest,
    required this.lowest,
    required this.standardDeviation,
    required this.percentile25,
    required this.percentile75,
    required this.percentile90,
  });

  factory StatisticalSummary.empty() {
    return StatisticalSummary(
      mean: 0,
      median: 0,
      highest: 0,
      lowest: 0,
      standardDeviation: 0,
      percentile25: 0,
      percentile75: 0,
      percentile90: 0,
    );
  }
}

StatisticalSummary calculateStats(List<double>? numbers) {
  if (numbers == null || numbers.isEmpty) return StatisticalSummary.empty();

  // Sort the list
  numbers.sort();

  // Calculate highest and lowest
  final highest = numbers.last;
  final lowest = numbers.first;

  // Calculate mean
  final sum = numbers.reduce((a, b) => a + b);
  final mean = sum / numbers.length;

  // Calculate median
  double median;
  final middle = numbers.length ~/ 2;
  if (numbers.length % 2 == 0) {
    median = (numbers[middle - 1] + numbers[middle]) / 2;
  } else {
    median = numbers[middle];
  }

  // Calculate 25th, 75th, and 90th percentiles
  double percentile25 = calculatePercentile(numbers, 25);
  double percentile75 = calculatePercentile(numbers, 75);
  double percentile90 = calculatePercentile(numbers, 90);

  // Calculate standard deviation
  final variance =
      numbers.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
          numbers.length;
  final standardDeviation = sqrt(variance);

  return StatisticalSummary(
    mean: mean,
    median: median,
    highest: highest,
    lowest: lowest,
    standardDeviation: standardDeviation,
    percentile25: percentile25,
    percentile75: percentile75,
    percentile90: percentile90,
  );
}

double calculatePercentile(List<double> sortedNumbers, double percentile) {
  int n = sortedNumbers.length;
  double index = percentile * (n + 1) / 100;
  int k = index.toInt();
  double d = index - k;

  // Boundary cases
  if (k <= 0) return sortedNumbers.first;
  if (k >= n) return sortedNumbers.last;

  return sortedNumbers[k - 1] + d * (sortedNumbers[k] - sortedNumbers[k - 1]);
}

extension TopNX on Map<String, int> {
  Map<String, int> topN([int? n]) {
    final sorted = entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (n == null) {
      return {
        for (final entry in sorted) entry.key: entry.value,
      };
    }

    return {
      for (final entry in sorted.take(n)) entry.key: entry.value,
    };
  }
}
