// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';
import '../types/download_repository.dart';
import '../types/download_repository_factory.dart';
import 'repo_empty.dart';

const kDownloadDbName = 'download.db';

final downloadRepositoryFactoryProvider = Provider<DownloadRepositoryFactory>(
  (_) => const EmptyDownloadRepositoryFactory(),
);

final downloadRepositoryProvider = FutureProvider<DownloadRepository>(
  (ref) => ref.watch(internalDownloadRepositoryProvider.future),
);

final internalDownloadRepositoryProvider = FutureProvider<DownloadRepository>(
  (ref) async {
    final factory = ref.watch(downloadRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final class EmptyDownloadRepositoryFactory
    implements DownloadRepositoryFactory {
  const EmptyDownloadRepositoryFactory();

  @override
  Future<DownloadRepository> create() async => DownloadRepositoryEmpty();

  @override
  Future<void> dispose(DownloadRepository repository) async {}
}

Future<String> getDownloadsDbPath(AppFileSystem fs) async => '';
