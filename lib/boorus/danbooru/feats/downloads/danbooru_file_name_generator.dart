// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/path.dart';

String generateLegacyBoorusamaFilenameFor(DanbooruPost item, String fileUrl) =>
    '${generateFullReadableName(item)} - ${basename(fileUrl)}'
        .fixInvalidCharacterForPathName();

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
  }
}
