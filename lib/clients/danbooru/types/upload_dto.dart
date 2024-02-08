// Project imports:
import 'types.dart';

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
  final List<UploadMediaAssetsDto>? uploadMediaAssets;
  final List<dynamic>? posts;
  final UserDto? uploader;
  final List<MediaAssetDto>? mediaAssets;

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
    this.uploadMediaAssets,
    this.posts,
    this.uploader,
    this.mediaAssets,
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
      uploadMediaAssets: (json['upload_media_assets'] as List?)
          ?.map((e) => UploadMediaAssetsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      posts: json['posts'] as List?,
      uploader: json['uploader'] == null
          ? null
          : UserDto.fromJson(json['uploader'] as Map<String, dynamic>),
      mediaAssets: (json['media_assets'] as List?)
          ?.map((e) => MediaAssetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UploadMediaAssetsDto {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? uploadId;
  final int? mediaAssetId;
  final String? status;
  final String? sourceUrl;
  final String? error;
  final String? pageUrl;

  UploadMediaAssetsDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.uploadId,
    this.mediaAssetId,
    this.status,
    this.sourceUrl,
    this.error,
    this.pageUrl,
  });

  factory UploadMediaAssetsDto.fromJson(Map<String, dynamic> json) {
    return UploadMediaAssetsDto(
      id: json['id'] as int?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at']),
      uploadId: json['upload_id'] as int?,
      mediaAssetId: json['media_asset_id'] as int?,
      status: json['status'] as String?,
      sourceUrl: json['source_url'] as String?,
      error: json['error'] as String?,
      pageUrl: json['page_url'] as String?,
    );
  }
}
