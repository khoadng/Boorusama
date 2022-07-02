abstract class IDownloadService<T> {
  void download(
    T item, {
    String? path,
  });
  Future<void> init();
  void dispose();
}
