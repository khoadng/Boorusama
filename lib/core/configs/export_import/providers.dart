// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/feats/backup/data_io_handler.dart';

final booruConfigFileHandlerProvider = Provider<BooruConfigIOHandler>((ref) {
  return BooruConfigIOHandler(
    handler: DataIOHandler.file(
      version: kBooruConfigsExporterImporterVersion,
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_profiles',
    ),
  );
});
