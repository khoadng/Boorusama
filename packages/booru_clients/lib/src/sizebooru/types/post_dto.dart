class SizebooruPostDto {
  SizebooruPostDto({
    required this.id,
    required this.tags,
    this.thumbnailUrl,
    this.fileUrl,
    this.filename,
    this.source,
    this.artist,
    this.uploader,
    this.createdAt,
    this.score,
  });

  final int id;
  final List<String> tags;
  final String? thumbnailUrl;
  final String? fileUrl;
  final String? filename;
  final String? source;
  final String? artist;
  final String? uploader;
  final DateTime? createdAt;
  final int? score;

  @override
  String toString() => id.toString();
}
