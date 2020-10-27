import 'package:path/path.dart' as path;
import 'package:boorusama/domain/posts/post.dart';

class FileNameGenerator {
  String generateFor(Post post, String fileUrl) {
    final copyrights = post.tagStringCopyright.split(' ').toList();
    final charaters = post.tagStringCharacter.split(' ').toList();
    final cleanedCharacterList = List<String>();

    // Remove copyright string in character name
    for (var character in charaters) {
      final index = character.indexOf("(");
      var cleanedName = character;

      if (index > 0) {
        cleanedName = character.substring(0, index - 1);
      }

      cleanedCharacterList.add(cleanedName);
    }

    var characterString = cleanedCharacterList.take(3).join(", ");
    var remainedCharacterString = cleanedCharacterList.skip(3).isEmpty
        ? ""
        : " and ${cleanedCharacterList.skip(3).length} more";
    var remainedCopyrightString = copyrights.skip(1).isEmpty
        ? ""
        : " and ${copyrights.skip(1).length} more";

    return "$characterString$remainedCharacterString (${copyrights.first}$remainedCopyrightString) drawn by ${post.tagStringArtist} - ${path.basename(fileUrl)}"
        .fixInvalidCharacterForPathName();
  }
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return this.replaceAll(RegExp(r'[\\/*?:"<>|]'), "_");
  }
}
