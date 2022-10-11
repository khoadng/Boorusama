abstract class IDownloadService<T> {
  Future<void> download(
    T item, {
    String? path,
  });
  Future<void> init();
  void dispose();
}
