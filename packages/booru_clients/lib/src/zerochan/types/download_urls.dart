class ZerochanDownloadUrls {
  const ZerochanDownloadUrls({
    this.full,
    this.large,
    this.medium,
    this.small,
  });

  final String? full;
  final String? large;
  final String? medium;
  final String? small;

  bool get isUseful => [full, large, medium, small].any(
    (url) => url?.isNotEmpty == true,
  );
}
