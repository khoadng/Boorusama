import 'package:hive_ce/hive.dart';

import '../../../../../../core/configs/config/types.dart';

abstract interface class DanbooruUploadHideBoxFactory {
  Future<Box<String>> create(BooruConfigAuth config);

  Future<void> dispose(Box<String> box);
}

final class HiveDanbooruUploadHideBoxFactory
    implements DanbooruUploadHideBoxFactory {
  const HiveDanbooruUploadHideBoxFactory();

  @override
  Future<Box<String>> create(BooruConfigAuth config) => Hive.openBox<String>(
    '${Uri.encodeComponent(config.url)}_hide_uploads_v1',
  );

  @override
  Future<void> dispose(Box<String> box) => box.close();
}
