class PostSummaryDto {
  const PostSummaryDto({
    this.id,
    this.sha256,
    this.hash,
    this.md5,
    this.blurhash,
    this.width,
    this.height,
    this.extension,
    this.mime,
    this.posted,
  });

  factory PostSummaryDto.fromJson(Map<String, dynamic> json) {
    return PostSummaryDto(
      id: json['id'] as int?,
      sha256: json['sha256'] as String?,
      hash: json['hash'] as String?, // deprecated
      md5: json['md5'] as String?,
      blurhash: json['blurhash'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      extension: json['extension'] as String?,
      mime: json['mime'] as int?,
      posted: json['posted'] as String?,
    );
  }

  final int? id;
  final String? sha256;
  final String? hash; // deprecated
  final String? md5;
  final String? blurhash;
  final int? width;
  final int? height;
  final String? extension;
  final int? mime;
  final String? posted;

  @override
  String toString() => '$id: ${sha256 ?? hash}';
}
