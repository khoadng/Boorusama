class PostDto {
  final int? id;
  final int? width;
  final int? height;
  final String? thumbnail;
  final String? source;
  final String? tag;
  final List<String>? tags;

  PostDto({
    this.id,
    this.width,
    this.height,
    this.thumbnail,
    this.source,
    this.tag,
    this.tags,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      width: json['width'],
      height: json['height'],
      thumbnail: json['thumbnail'],
      source: json['source'],
      tag: json['tag'],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  @override
  String toString() => id.toString();
}

extension PostDtoX on PostDto {
  String? fileUrl() => thumbnail
      ?.replaceAll(RegExp(r'/s\d+\.zerochan'), '/static.zerochan')
      .replaceAll('.240.', '.full.')
      .replaceAll('.600.', '.full.')
      .replaceAll('/240/', '/full/')
      .replaceAll('/600/', '/full/');

  String? sampleUrl() => thumbnail
      ?.replaceAll(RegExp(r'/s\d+\.zerochan'), '/s3.zerochan')
      .replaceAll('.240.', '.600.')
      .replaceAll('/240/', '/600/');
}
