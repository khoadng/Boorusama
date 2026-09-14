// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../types/bookmark_repository.dart';
import '../../types/bookmark_repository_factory.dart';
import 'bookmark_hive_object.dart';
import 'repository.dart';

final class HiveBookmarkRepositoryFactory implements BookmarkRepositoryFactory {
  const HiveBookmarkRepositoryFactory({this.boxName = 'favorites'});

  final String boxName;

  @override
  Future<BookmarkRepository> create() async {
    final box = await Hive.openBox<BookmarkHiveObject>(boxName);
    return BookmarkHiveRepository(box);
  }

  @override
  Future<void> dispose(BookmarkRepository repository) async {
    if (repository case final BookmarkHiveRepository hiveRepository) {
      await hiveRepository.close();
    }
  }
}
