enum DownloadQuality {
  original,
  sample,
  preview;

  factory DownloadQuality.parse(dynamic value) => switch (value) {
    'original' || '0' || 0 => original,
    'sample' || '1' || 1 => sample,
    'preview' || '2' || 2 => preview,
    _ => defaultValue,
  };

  static const DownloadQuality defaultValue = original;

  dynamic toData() => index;
}
