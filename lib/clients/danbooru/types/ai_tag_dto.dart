// Project imports:
import 'tag_dto.dart';

class AITagDto {
  AITagDto({
    required this.score,
    required this.tag,
  });

  final int? score;
  final TagDto? tag;

  factory AITagDto.fromJson(Map<String, dynamic> json) {
    return AITagDto(
      score: json['score'],
      tag: json['tag'] != null ? TagDto.fromJson(json['tag']) : null,
    );
  }
}
