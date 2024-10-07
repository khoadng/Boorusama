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

AnimePicturesTagType? tagTypeFromInt(dynamic type) => switch (type) {
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

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'],
      tag: json['tag'],
      tagRu: json['tag_ru'],
      tagJp: json['tag_jp'],
      num: json['num'],
      numPub: json['num_pub'],
      type: tagTypeFromInt(json['type']),
      alias: json['alias'],
      parent: json['parent'],
      views: json['views'],
    );
  }
}
