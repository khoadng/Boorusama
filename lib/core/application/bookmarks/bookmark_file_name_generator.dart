import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class BookmarkFileNameGenerator implements FileNameGenerator<Bookmark> {
  @override
  String generateFor(Bookmark item) => item.md5;
}
