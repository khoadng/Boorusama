// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../foundation/filesystem.dart';

abstract interface class DanbooruCreatorBoxFactory {
  Future<Box> create(BooruConfigAuth config);

  Future<void> dispose(Box box);
}

final class HiveDanbooruCreatorBoxFactory implements DanbooruCreatorBoxFactory {
  const HiveDanbooruCreatorBoxFactory({required this.fileSystem});

  final AppFileSystem fileSystem;

  @override
  Future<Box> create(BooruConfigAuth config) async {
    final tempPath = await fileSystem.getTemporaryPath();
    return Hive.openBox(
      '${Uri.encodeComponent(config.url)}_creators_v1',
      path: tempPath,
    );
  }

  @override
  Future<void> dispose(Box box) => box.close();
}
