// Project imports:
import 'package:boorusama/core/domain/file_name_generator.dart';

abstract class DownloadService<T> {
  Future<void> download(
    T item, {
    String? path,
    String? folderName,
    required FileNameGenerator fileNameGenerator,
  });
  Future<void> init();
  void dispose();
}
