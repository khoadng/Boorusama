enum UploadDateRangeSelectorType {
  last7Days,
  last30Days,
  last3Months,
  last6Months,
  lastYear,
}

extension UploadDateRangeSelectorTypeExtension on UploadDateRangeSelectorType {
  String get name => switch (this) {
        UploadDateRangeSelectorType.last7Days => 'Last 7 days',
        UploadDateRangeSelectorType.last30Days => 'Last 30 days',
        UploadDateRangeSelectorType.last3Months => 'Last 3 months',
        UploadDateRangeSelectorType.last6Months => 'Last 6 months',
        UploadDateRangeSelectorType.lastYear => 'Last year'
      };
}
