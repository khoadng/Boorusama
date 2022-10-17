// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';

class RelatedTagDto {
  const RelatedTagDto({
    required this.query,
    required this.category,
    required this.tags,
  });

  factory RelatedTagDto.fromJson(Map<String, dynamic> json) => RelatedTagDto(
        query: json['query'],
        category: json['category'],
        tags: List<List<dynamic>>.from(
            json['tags'].map((x) => List<dynamic>.from(x.map((x) => x)))),
      );

  final String query;
  final dynamic category;
  final List<List<dynamic>> tags;
}

RelatedTag relatedTagDtoToRelatedTag(RelatedTagDto dto) => RelatedTag(
      query: dto.query,
      tags: dto.tags
          .map((e) => RelatedTagItem(
                tag: e[0] as String,
                category: intToTagCategory(e[1] as int),
              ))
          .toList(),
    );
