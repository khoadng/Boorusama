// Project imports:
import 'package:boorusama/dart.dart';
import 'danbooru_post.dart';

typedef DanbooruPostStats = ({
  Map<String, int> copyrights,
  Map<String, int> characters,
  Map<String, int> uploaders,
  Map<String, int> approvers,
  StatisticalSummary fileSizes,
});

extension DanbooruPostStatsX on List<DanbooruPost> {
  DanbooruPostStats getDanbooruStats() {
    final characters = expand((e) => e.characterTags).toList();
    final characterMap = characters.count(selector: (e) => e);
    final copyrights = expand((e) => e.copyrightTags).toList();
    final copyrightMap = copyrights.count(selector: (e) => e);
    final fileSizes = map((e) => e.fileSize.toDouble()).toList();
    final uploaders = map((e) => e.uploaderId).toList();
    final approvers = map((e) => e.approverId).toList();

    return (
      characters: characterMap,
      copyrights: copyrightMap,
      fileSizes: calculateStats(fileSizes),
      uploaders: uploaders.count(selector: (e) => e.toString()),
      approvers:
          approvers.count(selector: (e) => e != null ? e.toString() : '<None>'),
    );
  }
}
