// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../types/favorite_tag.dart';
import '../types/favorite_tag_repository_factory.dart';
import 'favorite_tag_hive_object.dart';
import 'favorite_tag_repository_hive.dart';

final class HiveFavoriteTagRepositoryFactory
    implements FavoriteTagRepositoryFactory {
  const HiveFavoriteTagRepositoryFactory({this.boxName = 'favorite_tags'});

  final String boxName;

  @override
  Future<FavoriteTagRepository> create() async {
    final box = await Hive.openBox<FavoriteTagHiveObject>(boxName);
    return FavoriteTagRepositoryHive(box);
  }

  @override
  Future<void> dispose(FavoriteTagRepository repository) async {
    if (repository case final FavoriteTagRepositoryHive hiveRepository) {
      await hiveRepository.close();
    }
  }
}
