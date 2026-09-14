// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../user_metatag_repository.dart';

abstract interface class DanbooruUserMetatagRepositoryFactory {
  Future<UserMetatagRepository> create();

  Future<void> dispose(UserMetatagRepository repository);
}

final class HiveDanbooruUserMetatagRepositoryFactory
    implements DanbooruUserMetatagRepositoryFactory {
  const HiveDanbooruUserMetatagRepositoryFactory();

  @override
  Future<UserMetatagRepository> create() async {
    final box = await Hive.openBox<String>('user_metatags');
    if (box.isEmpty) {
      for (final tag in ['age', 'rating', 'order', 'score', 'id', 'user']) {
        await box.put(tag, tag);
      }
    }
    return UserMetatagRepository(box: box);
  }

  @override
  Future<void> dispose(UserMetatagRepository repository) =>
      repository.box.close();
}
