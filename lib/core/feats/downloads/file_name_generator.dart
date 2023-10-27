@deprecated
abstract class FileNameGenerator<T> {
  String generateFor(
    T item,
    String fileUrl,
  );
}
