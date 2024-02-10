// Project imports:
import 'types.dart';

class IqdbResultDto {
  final String? hash;
  final int? postId;
  final double? score;
  final PostDto? post;

  IqdbResultDto({
    required this.hash,
    required this.postId,
    required this.score,
    required this.post,
  });

  factory IqdbResultDto.fromJson(Map<String, dynamic> json) {
    return IqdbResultDto(
      hash: json['hash'],
      postId: json['post_id'],
      score: json['score'],
      post: json['post'] != null ? PostDto.fromJson(json['post']) : null,
    );
  }
}
