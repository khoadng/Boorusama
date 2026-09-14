// Project imports:
import 'download_repository.dart';

abstract interface class DownloadRepositoryFactory {
  Future<DownloadRepository> create();

  Future<void> dispose(DownloadRepository repository);
}
