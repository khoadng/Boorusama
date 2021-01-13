import 'package:flutter_riverpod/all.dart';
import 'package:path/path.dart' as path;
import 'package:boorusama/domain/posts/post.dart';

final fileNameGeneratorProvider =
    Provider<FileNameGenerator>((ref) => FileNameGenerator());

class FileNameGenerator {
  String generateFor(Post post, String fileUrl) {
    return "${post.name.full} - ${path.basename(fileUrl)}"
        .fixInvalidCharacterForPathName();
  }
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return this.replaceAll(RegExp(r'[\\/*?:"<>|]'), "_");
  }
}
