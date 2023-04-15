abstract class BulkDownloader<T> {
  Future<String> getDownloadDirPath();

  Future<void> enqueueDownload(
    T downloadable, {
    String? folder,
  });

  Future<void> cancelAll();

  Stream<DownloadData> get stream;

  bool get isInit;

  Future<void> init();

  void dispose();
}

class DownloadData {
  const DownloadData(
    this.itemId,
    this.path,
    this.fileName,
  );

  final int itemId;
  final String path;
  final String fileName;
}
