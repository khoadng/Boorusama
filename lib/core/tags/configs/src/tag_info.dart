// Project imports:
import '../../metatag/metatag.dart';

class TagInfo {
  const TagInfo({
    required this.metatags,
    required this.defaultBlacklistedTags,
    required this.r18Tags,
  });

  final Set<Metatag> metatags;
  final Set<String> defaultBlacklistedTags;
  final Set<String> r18Tags;
}
