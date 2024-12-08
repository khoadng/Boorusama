// Project imports:
import 'tag_dto.dart';

class AITagDto {
  AITagDto({
    required this.score,
    required this.tag,
  });

  factory AITagDto.fromJson(Map<String, dynamic> json) {
    return AITagDto(
      score: json['score'],
      tag: json['tag'] != null ? TagDto.fromJson(json['tag']) : null,
    );
  }

  final int? score;
  final TagDto? tag;
}
