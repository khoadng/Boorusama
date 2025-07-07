// Project imports:
import '../../rating/rating.dart';

class TagFilterData {
  TagFilterData({
    required this.tags,
    required this.rating,
    required this.score,
    this.downvotes,
    this.uploaderId,
    this.uploaderName,
    this.source,
    this.id,
  });

  TagFilterData.tags({
    required this.tags,
  }) : rating = Rating.general,
       score = 0,
       source = null,
       uploaderId = null,
       uploaderName = null,
       id = null,
       downvotes = null;

  final Set<String> tags;
  final Rating rating;
  final int score;
  final int? downvotes;
  final int? uploaderId;
  final String? uploaderName;
  final String? source;
  final int? id;
}

extension TagFilterDataX on Set<String> {
  TagFilterData toTagFilterData() => TagFilterData.tags(
    tags: map((tag) => tag.toLowerCase()).toSet(),
  );
}
