// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/download_repository.dart';
import 'repo_empty.dart';

const kDownloadDbName = 'download.db';

final downloadRepositoryProvider = FutureProvider<DownloadRepository>((
  ref,
) async {
  final repo = await ref.watch(internalDownloadRepositoryProvider.future);

  return repo;
});

final internalDownloadRepositoryProvider = FutureProvider<DownloadRepository>(
  (ref) => DownloadRepositoryEmpty(),
);

Future<String> getDownloadsDbPath() async {
  return '';
}
