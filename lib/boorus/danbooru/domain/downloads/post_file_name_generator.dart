// Package imports:
import 'package:path/path.dart' as path;
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/utils.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class PostFileNameGenerator implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item) =>
      '${generateFullReadableName(item)} - ${path.basename(item.downloadUrl)}'
          .fixInvalidCharacterForPathName();
}

class Md5OnlyFileNameGenerator implements FileNameGenerator<DanbooruPost> {
  @override
  String generateFor(DanbooruPost item) =>
      '${item.md5}${extension(item.downloadUrl)}';
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
  }
}
