// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'bookmark_builder.dart';
import 'bookmark_repository.dart';

BooruComponents createBookmarks() => BooruComponents(
  parser: DefaultBooruParser(config: BooruYamlConfigs.bookmarks),
  createBuilder: () => BookmarkBooruBuilder(),
  createRepository: (ref) => BookmarkBooruRepository(ref),
);
