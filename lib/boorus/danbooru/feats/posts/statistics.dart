// Project imports:
import 'package:boorusama/dart.dart';
import 'danbooru_post.dart';

typedef DanbooruPostStats = ({
  Map<String, int> copyrights,
  Map<String, int> characters,
  StatisticalSummary fileSizes,
});

extension DanbooruPostStatsX on List<DanbooruPost> {
  DanbooruPostStats getDanbooruStats() {
    final characters = expand((e) => e.characterTags).toList();
    final characterMap = characters.count(selector: (e) => e);
    final copyrights = expand((e) => e.copyrightTags).toList();
    final copyrightMap = copyrights.count(selector: (e) => e);
    final fileSizes = map((e) => e.fileSize.toDouble()).toList();

    return (
      characters: characterMap,
      copyrights: copyrightMap,
      fileSizes: calculateStats(fileSizes),
    );
  }
}
