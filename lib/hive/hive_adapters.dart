import 'package:hive_ce/hive.dart';
import '../core/blacklists/src/data/hive/tag_hive_object.dart';
import '../core/bookmarks/src/data/hive/bookmark_hive_object.dart';
import '../core/tags/favorites/src/data/favorite_tag_hive_object.dart';

@GenerateAdapters([
  AdapterSpec<FavoriteTagHiveObject>(),
  AdapterSpec<BlacklistedTagHiveObject>(),
  AdapterSpec<BookmarkHiveObject>(),
])
part 'hive_adapters.g.dart';
