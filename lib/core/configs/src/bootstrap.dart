// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'booru_config.dart';
import 'data/booru_config_repository_hive.dart';

Future<BooruConfigRepository> createBooruConfigsRepo({
  required BootLogger logger,
  required BooruFactory booruFactory,
  required Future<void> Function(int configId) onCreateNew,
}) async {
  Box<String> booruConfigBox;
  logger.l('Initialize booru config box');
  if (await Hive.boxExists('booru_configs')) {
    logger.l('Open booru config box');
    booruConfigBox = await Hive.openBox<String>('booru_configs');
  } else {
    logger.l('Create booru config box');
    booruConfigBox = await Hive.openBox<String>('booru_configs');
    logger.l('Add default booru config');

    final id = await booruConfigBox
        .add(HiveBooruConfigRepository.defaultValue(booruFactory));

    await onCreateNew(id);
  }

  logger.l('Total booru config: ${booruConfigBox.length}');

  logger.l('Initialize booru user repository');
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  return booruUserRepo;
}
