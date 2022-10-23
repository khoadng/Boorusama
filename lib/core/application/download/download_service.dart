abstract class DownloadService<T> {
  Future<void> download(
    T item, {
    String? path,
    String? folderName,
  });
  Future<void> init();
  void dispose();
}
