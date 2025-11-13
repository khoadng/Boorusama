abstract class DownloadObserver {
  void onSingleDownloadStart();

  void onBulkDownloadStart({
    required int total,
  });
}

class NoOpDownloadObserver implements DownloadObserver {
  const NoOpDownloadObserver();

  @override
  void onSingleDownloadStart() {}

  @override
  void onBulkDownloadStart({
    required int total,
  }) {}
}
