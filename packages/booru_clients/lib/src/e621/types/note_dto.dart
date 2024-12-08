class NoteDto {
  NoteDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.creatorId,
    this.x,
    this.y,
    this.width,
    this.height,
    this.version,
    this.isActive,
    this.postId,
    this.body,
    this.creatorName,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      creatorId: json['creator_id'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      version: json['version'],
      isActive: json['is_active'],
      postId: json['post_id'],
      body: json['body'],
      creatorName: json['creator_name'],
    );
  }

  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final int? creatorId;
  final int? x;
  final int? y;
  final int? width;
  final int? height;
  final int? version;
  final bool? isActive;
  final int? postId;
  final String? body;
  final String? creatorName;

  @override
  String toString() => body ?? '';
}
