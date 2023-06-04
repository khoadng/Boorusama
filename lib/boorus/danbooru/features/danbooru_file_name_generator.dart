// Package imports:
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/features/posts/utils.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class BoorusamaStyledFileNameGenerator
    implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item, String fileUrl) =>
      '${generateFullReadableName(item)} - ${basename(fileUrl)}'
          .fixInvalidCharacterForPathName();
}

class DanbooruMd5OnlyFileNameGenerator
    implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item, String fileUrl) =>
      '${item.md5}${extension(fileUrl)}';
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
  }
}
