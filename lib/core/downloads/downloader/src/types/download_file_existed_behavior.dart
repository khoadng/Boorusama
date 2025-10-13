enum DownloadFileExistedBehavior {
  appDecide,
  skip,
  overwrite;

  factory DownloadFileExistedBehavior.parse(dynamic value) => switch (value) {
    'appDecide' || '0' || 0 => appDecide,
    'skip' || '1' || 1 => skip,
    'overwrite' || '2' || 2 => overwrite,
    _ => defaultValue,
  };

  static const DownloadFileExistedBehavior defaultValue = appDecide;

  bool get skipDownloadIfExists => this == skip;

  dynamic toData() => index;
}
