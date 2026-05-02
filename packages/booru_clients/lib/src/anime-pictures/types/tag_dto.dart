// Project imports:
import 'json_parsing.dart';

enum AnimePicturesTagType {
  unknown,
  character,
  reference,
  copyrightProduct,
  author,
  copyrightGame,
  copyrightOther,
  object,
}

AnimePicturesTagType? tagTypeFromInt(dynamic type) =>
    switch (intFromJson(type)) {
      0 => AnimePicturesTagType.unknown,
      1 => AnimePicturesTagType.character,
      2 => AnimePicturesTagType.reference,
      3 => AnimePicturesTagType.copyrightProduct,
      4 => AnimePicturesTagType.author,
      5 => AnimePicturesTagType.copyrightGame,
      6 => AnimePicturesTagType.copyrightOther,
      7 => AnimePicturesTagType.object,
      _ => null,
    };

class TagDto {
  const TagDto({
    required this.id,
    required this.tag,
    required this.tagRu,
    required this.tagJp,
    required this.num,
    required this.numPub,
    required this.type,
    required this.alias,
    required this.parent,
    required this.views,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: intFromJson(json['id']),
      tag: stringFromJson(json['tag']),
      tagRu: stringFromJson(json['tag_ru']),
      tagJp: stringFromJson(json['tag_jp']),
      num: intFromJson(json['num']),
      numPub: intFromJson(json['num_pub']),
      type: tagTypeFromInt(json['type']),
      alias: stringFromJson(json['alias']),
      parent: intFromJson(json['parent']),
      views: intFromJson(json['views']),
    );
  }

  final int? id;
  final String? tag;
  final String? tagRu;
  final String? tagJp;
  final int? num;
  final int? numPub;
  final AnimePicturesTagType? type;
  final String? alias;
  final int? parent;
  final int? views;
}
