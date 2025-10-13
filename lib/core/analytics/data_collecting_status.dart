enum DataCollectingStatus {
  allow,
  prohibit;

  factory DataCollectingStatus.parse(dynamic value) => switch (value) {
    'allow' || '0' || 0 => allow,
    'prohibit' || '1' || 1 => prohibit,
    _ => defaultValue,
  };

  static const DataCollectingStatus defaultValue = allow;

  dynamic toData() => index;
}
