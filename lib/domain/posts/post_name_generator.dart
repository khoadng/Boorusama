import 'package:flutter_riverpod/all.dart';
import 'package:path/path.dart' as path;

import 'post.dart';

final postNameGeneratorProvider =
    Provider<PostNameGenerator>((ref) => PostNameGenerator());

class PostNameGenerator {
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
