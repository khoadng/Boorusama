// Project imports:
import '../models/danbooru_post.dart';

String generateFullReadableName(DanbooruPost post) =>
    '${generateCharacterOnlyReadableName(post)} (${generateCopyrightOnlyReadableName(post)}) drawn by ${post.artistTags.join(' ')}';

String generateCopyrightOnlyReadableName(DanbooruPost post) {
  final copyrights = post.copyrightTags;
  final copyright = copyrights.isEmpty ? 'original' : copyrights.first;

  final remainedCopyrightString = copyrights.skip(1).isEmpty
      ? ''
      : ' and ${copyrights.skip(1).length} more';

  return '$copyright$remainedCopyrightString';
}

String generateCharacterOnlyReadableName(DanbooruPost post) {
  final charaters = post.characterTags;
  final cleanedCharacterList = [];

  // Remove copyright string in character name
  for (final character in charaters) {
    final index = character.indexOf('(');
    var cleanedName = character;

    if (index > 0) {
      cleanedName = character.substring(0, index - 1);
    }

    if (!cleanedCharacterList.contains(cleanedName)) {
      cleanedCharacterList.add(cleanedName);
    }
  }

  final characterString = cleanedCharacterList.take(3).join(', ');
  final remainedCharacterString = cleanedCharacterList.skip(3).isEmpty
      ? ''
      : ' and ${cleanedCharacterList.skip(3).length} more';

  return '${characterString.isEmpty ? 'original' : characterString}$remainedCharacterString';
}
