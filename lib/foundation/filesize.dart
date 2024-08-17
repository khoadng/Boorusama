typedef IndexToUnitMapper = String Function(int index);
typedef FizesizeFormatter = String Function(String size, String unit);

const _binaryScalingFactors = [
  1,
  1024,
  1024 * 1024,
  1024 * 1024 * 1024,
  1024 * 1024 * 1024 * 1024,
  1024 * 1024 * 1024 * 1024 * 1024,
  1024 * 1024 * 1024 * 1024 * 1024 * 1024,
];

const _kiloScalingFactors = [
  1,
  1000,
  1000 * 1000,
  1000 * 1000 * 1000,
  1000 * 1000 * 1000 * 1000,
  1000 * 1000 * 1000 * 1000 * 1000,
  1000 * 1000 * 1000 * 1000 * 1000 * 1000,
];

const _defaultUnits = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
const _binaryUnits = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB'];

String _defaultUnitBuilder(int index, List<String> units) {
  if (units.isEmpty) return '';

  if (index < 0) return units[0];
  if (index >= units.length) return units.last;

  return units[index];
}

String _defaultFormatter(String size, String unit) => '$size $unit';

class FilesizeOptions {
  const FilesizeOptions._({
    required this.divider,
    required this.scalingFactors,
    required this.unitBuilder,
    required this.formatter,
  });

  factory FilesizeOptions.custom({
    required int divider,
    IndexToUnitMapper? unitBuilder,
    FizesizeFormatter? formatter,
  }) =>
      FilesizeOptions._(
        divider: divider,
        scalingFactors: null,
        unitBuilder:
            unitBuilder ?? (idx) => _defaultUnitBuilder(idx, _defaultUnits),
        formatter: formatter ?? _defaultFormatter,
      );

  factory FilesizeOptions() => FilesizeOptions._(
        divider: 1024,
        scalingFactors: _binaryScalingFactors,
        unitBuilder: (idx) => _defaultUnitBuilder(idx, _defaultUnits),
        formatter: _defaultFormatter,
      );

  factory FilesizeOptions.binary() => FilesizeOptions._(
        divider: 1024,
        scalingFactors: _binaryScalingFactors,
        unitBuilder: (idx) => _defaultUnitBuilder(idx, _binaryUnits),
        formatter: _defaultFormatter,
      );

  factory FilesizeOptions.si() => FilesizeOptions._(
        divider: 1000,
        scalingFactors: _kiloScalingFactors,
        unitBuilder: (idx) => _defaultUnitBuilder(idx, _defaultUnits),
        formatter: _defaultFormatter,
      );

  final int divider;
  final List<int>? scalingFactors;
  final IndexToUnitMapper unitBuilder;
  final FizesizeFormatter formatter;

  FilesizeOptions copyWith({
    IndexToUnitMapper? unitBuilder,
    FizesizeFormatter? formatter,
  }) =>
      FilesizeOptions._(
        divider: divider,
        scalingFactors: scalingFactors,
        unitBuilder: unitBuilder ?? this.unitBuilder,
        formatter: formatter ?? this.formatter,
      );
}

abstract class Filesize {
  const Filesize._();

  static String? tryParse(
    int? size, {
    int round = 2,
    FilesizeOptions? options,
  }) {
    if (size == null || size < 0) return null;

    final opt = options ?? FilesizeOptions();
    final divider = opt.divider;
    final unitBuilder = opt.unitBuilder;
    final formatter = opt.formatter;
    final scalingFactors = opt.scalingFactors;

    if (size == 0) return formatter('0', unitBuilder(0));

    // For size less than 1 KB, return the size in bytes.
    if (size < divider) return formatter(size.toString(), unitBuilder(0));

    final (value, idx) = scalingFactors == null
        ? _unknownCalculateSize(size, divider)
        : _precomputeCalculateSize(size, scalingFactors);

    final formattedSize = value.toStringAsFixed(round);
    final unit = unitBuilder(idx);

    return formatter(formattedSize, unit);
  }

  static (double, int) _unknownCalculateSize(int size, int divider) {
    var idx = 0;
    var value = size.toDouble();

    while (value >= divider) {
      value /= divider;
      idx++;
    }

    return (value, idx);
  }

  static (double, int) _precomputeCalculateSize(
    int size,
    List<int> scalingFactors,
  ) {
    // Determine the index of the unit using precomputed factors
    var idx = 0;
    var value = size.toDouble();

    while (
        idx < scalingFactors.length - 1 && value >= scalingFactors[idx + 1]) {
      idx++;
    }

    // Convert value to appropriate unit and format with rounding
    value /= scalingFactors[idx];

    return (value, idx);
  }

  static String parse(
    int? size, {
    int round = 2,
    FilesizeOptions? options,
  }) =>
      tryParse(size, round: round, options: options) ?? 'N/A';
}
