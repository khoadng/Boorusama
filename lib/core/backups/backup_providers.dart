// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/package_info.dart';
import 'backups.dart';

final defaultBackupConverterProvider =
    Provider.family<DataBackupConverter, int>((ref, version) {
  return DataBackupConverter(
    version: version,
    exportVersion: ref.watch(appVersionProvider),
  );
});
