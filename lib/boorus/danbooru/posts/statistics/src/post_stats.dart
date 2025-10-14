// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../foundation/utils/collection_utils.dart';
import '../../../../../foundation/utils/statistics.dart';
import '../../post/types.dart';

class DanbooruPostStats extends Equatable {
  const DanbooruPostStats({
    required this.copyrights,
    required this.characters,
    required this.uploaders,
    required this.approvers,
    required this.fileSizes,
    required this.resolutions,
  });

  factory DanbooruPostStats.fromPosts(List<DanbooruPost> posts) {
    final characters = posts.expand((e) => e.characterTags).toList();
    final characterMap = characters.count(selector: (e) => e);
    final copyrights = posts.expand((e) => e.copyrightTags).toList();
    final copyrightMap = copyrights.count(selector: (e) => e);
    final fileSizes = posts.map((e) => e.fileSize.toDouble()).toList();
    final uploaders = posts.map((e) => e.uploaderId).toList();
    final approvers = posts.map((e) => e.approverId).toList();
    final resolutions = posts
        .where((e) => e.width > 0 && e.height > 0)
        .map((e) => '${e.width.toInt()} x ${e.height.toInt()}')
        .toList();

    return DanbooruPostStats(
      characters: characterMap,
      copyrights: copyrightMap,
      fileSizes: calculateStats(fileSizes),
      uploaders: uploaders.count(selector: (e) => e.toString()),
      approvers: approvers.count(
        selector: (e) => e != null ? e.toString() : '<None>',
      ),
      resolutions: resolutions.count(selector: (e) => e),
    );
  }

  final Map<String, int> copyrights;
  final Map<String, int> characters;
  final Map<String, int> uploaders;
  final Map<String, int> approvers;
  final StatisticalSummary fileSizes;
  final Map<String, int> resolutions;

  @override
  List<Object?> get props => [
    copyrights,
    characters,
    uploaders,
    approvers,
    fileSizes,
    resolutions,
  ];
}
