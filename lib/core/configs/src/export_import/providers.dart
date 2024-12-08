// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/backups/data_io_handler.dart';
import 'package:boorusama/core/backups/providers.dart';
import 'package:boorusama/foundation/device_info.dart';
import 'booru_config_io_handler.dart';

final booruConfigFileHandlerProvider = Provider<BooruConfigIOHandler>((ref) {
  final converter = ref.watch(
      defaultBackupConverterProvider(kBooruConfigsExporterImporterVersion));
  return BooruConfigIOHandler(
    converter: converter,
    handler: DataIOHandler.file(
      converter: converter,
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_profiles',
    ),
  );
});
