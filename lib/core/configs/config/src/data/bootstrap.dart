// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../types/booru_config_repository.dart';
import 'booru_config_repository_hive.dart';

Future<BooruConfigRepository> createBooruConfigsRepo({
  required BootLogger logger,
  required Future<void> Function(int configId)? onCreateNew,
}) async {
  logger.l('Initialize booru config box');

  final isNewBox = !await Hive.boxExists('booru_configs');

  final booruConfigBox = await Hive.openBox<String>('booru_configs');

  if (isNewBox && onCreateNew != null) {
    logger.l('Add default booru config');

    final id = await booruConfigBox.add(
      HiveBooruConfigRepository.defaultValue(),
    );

    await onCreateNew(id);
  }

  logger
    ..l('Total booru config: ${booruConfigBox.length}')
    ..l('Initialize booru user repository');
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  return booruUserRepo;
}
