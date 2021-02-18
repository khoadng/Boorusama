// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'wiki.dart';

part 'wiki_dto.freezed.dart';
part 'wiki_dto.g.dart';

@freezed
abstract class WikiDto with _$WikiDto {
  const factory WikiDto({
    int id,
    String created_at,
    String updated_at,
    String title,
    String body,
    bool is_locked,
    List<dynamic> other_names,
    bool is_deleted,
    int category_name,
  }) = _WikiDto;

  factory WikiDto.fromJson(Map<String, dynamic> json) =>
      _$WikiDtoFromJson(json);
}

extension WikiDtoX on WikiDto {
  Wiki toEntity() {
    return Wiki(
      body: body,
      id: id,
      title: title,
      otherNames: List<String>.from(other_names),
    );
  }
}
