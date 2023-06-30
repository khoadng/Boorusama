// Project imports:
import 'package:boorusama/boorus/core/utils.dart';
import 'danbooru_post.dart';

String generateFullReadableName(DanbooruPost post) =>
    '${generateCharacterOnlyReadableName(post.characterTags)} (${generateCopyrightOnlyReadableName(post.copyrightTags)}) drawn by ${post.artistTags.join(' ')}';
