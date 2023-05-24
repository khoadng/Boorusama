// Package imports:
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/utils.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class BoorusamaStyledFileNameGenerator
    implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item) =>
      '${generateFullReadableName(item)} - ${basename(item.downloadUrl)}'
          .fixInvalidCharacterForPathName();
}

class DanbooruMd5OnlyFileNameGenerator
    implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item) =>
      '${item.md5}${extension(item.downloadUrl)}';
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
  }
}
