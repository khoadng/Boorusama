enum UploadDateRange {
  last7Days,
  last30Days,
  last3Months,
  last6Months,
  lastYear,
}

extension UploadDateRangeX on UploadDateRange {
  String get name => switch (this) {
    UploadDateRange.last7Days => 'Last 7 days',
    UploadDateRange.last30Days => 'Last 30 days',
    UploadDateRange.last3Months => 'Last 3 months',
    UploadDateRange.last6Months => 'Last 6 months',
    UploadDateRange.lastYear => 'Last year',
  };
}
