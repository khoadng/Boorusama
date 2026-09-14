// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../../../foundation/filesystem.dart';
import 'sidecar_store.dart';

final sidecarStoreProvider = FutureProvider<SidecarStore>((ref) async {
  final fs = ref.watch(appFileSystemProvider);
  final storagePath = await fs.getAppStoragePath();
  return SidecarStore(
    directory: p.join(storagePath, 'download-sidecars'),
    fs: fs,
  );
}, name: 'sidecarStoreProvider');

final sidecarRecoveryProvider = FutureProvider<void>((ref) async {
  final store = await ref.watch(sidecarStoreProvider.future);
  await store.recover();
}, name: 'sidecarRecoveryProvider');
