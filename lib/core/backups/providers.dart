// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/info/package_info.dart';
import 'data_converter.dart';

final defaultBackupConverterProvider =
    Provider.family<DataBackupConverter, int>((ref, version) {
  return DataBackupConverter(
    version: version,
    exportVersion: ref.watch(appVersionProvider),
  );
});
