abstract class DownloadService<T> {
  Future<void> download(
    T item, {
    String? path,
  });
  Future<void> init();
  void dispose();
}
