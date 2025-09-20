// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../blacklists/src/data/hive/tag_hive_object.dart';
import '../bookmarks/src/data/hive/bookmark_hive_object.dart';
import '../tags/favorites/src/data/favorite_tag_hive_object.dart';

@GenerateAdapters([
  AdapterSpec<FavoriteTagHiveObject>(),
  AdapterSpec<BlacklistedTagHiveObject>(),
  AdapterSpec<BookmarkHiveObject>(),
])
part 'hive_adapters.g.dart';
