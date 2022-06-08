// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'post_statistics.g.dart';

@JsonSerializable()
class PostStatistics {
  final int favCount;
  final int commentCount;
  final bool isFavorited;

  PostStatistics({
    required this.favCount,
    required this.commentCount,
    required this.isFavorited,
  });

  factory PostStatistics.empty() =>
      PostStatistics(favCount: 0, commentCount: 0, isFavorited: false);

  factory PostStatistics.fromJson(Map<String, dynamic> json) =>
      _$PostStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$PostStatisticsToJson(this);
}
