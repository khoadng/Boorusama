class UploadDto {
  final int? id;
  final String? source;
  final int? uploaderId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? refererUrl;
  final String? error;
  final int? mediaAssetCount;
  final List<dynamic>? posts;

  UploadDto({
    this.id,
    this.source,
    this.uploaderId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.refererUrl,
    this.error,
    this.mediaAssetCount,
    this.posts,
  });

  factory UploadDto.fromJson(Map<String, dynamic> json) {
    return UploadDto(
      id: json['id'] as int?,
      source: json['source'] as String?,
      uploaderId: json['uploader_id'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at']),
      refererUrl: json['referer_url'] as String?,
      error: json['error'] as String?,
      mediaAssetCount: json['media_asset_count'] as int?,
      posts: json['posts'] as List<dynamic>?,
    );
  }
}

extension UploadDtoX on UploadDto {
  int get postedCount => posts?.length ?? 0;
}
