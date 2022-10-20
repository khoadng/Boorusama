// Package imports:
import 'package:path/path.dart' as path;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/utils.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class PostFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item) =>
      '${generateFullReadableName(item)} - ${path.basename(item.downloadUrl)}'
          .fixInvalidCharacterForPathName();
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
  }
}
