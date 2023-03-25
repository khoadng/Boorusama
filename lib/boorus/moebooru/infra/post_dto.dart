import 'package:equatable/equatable.dart';

class PostDto extends Equatable {
  const PostDto({
    this.id,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.creatorId,
    this.approverId,
    this.author,
    this.change,
    this.source,
    this.score,
    this.md5,
    this.fileSize,
    this.fileExt,
    this.fileUrl,
    this.isShownInIndex,
    this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    this.actualPreviewWidth,
    this.actualPreviewHeight,
    this.sampleUrl,
    this.sampleWidth,
    this.sampleHeight,
    this.sampleFileSize,
    this.jpegUrl,
    this.jpegWidth,
    this.jpegHeight,
    this.jpegFileSize,
    this.rating,
    this.isRatingLocked,
    this.hasChildren,
    this.parentId,
    this.status,
    this.isPending,
    this.width,
    this.height,
    this.isHeld,
    this.framesPendingString,
    this.framesPending,
    this.framesString,
    this.frames,
    this.isNoteLocked,
    this.lastNotedAt,
    this.lastCommentedAt,
  });

  PostDto fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      tags: json['tags'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      creatorId: json['creator_id'],
      approverId: json['approver_id'],
      author: json['author'],
      change: json['change'],
      source: json['source'],
      score: json['score'],
      md5: json['md5'],
      fileSize: json['file_size'],
      fileExt: json['file_ext'],
      fileUrl: json['file_url'],
      isShownInIndex: json['is_shown_in_index'],
      previewUrl: json['preview_url'],
      previewWidth: json['preview_width'],
      previewHeight: json['preview_height'],
      actualPreviewWidth: json['actual_preview_width'],
      actualPreviewHeight: json['actual_preview_height'],
      sampleUrl: json['sample_url'],
      sampleWidth: json['sample_width'],
      sampleHeight: json['sample_height'],
      sampleFileSize: json['sample_file_size'],
      jpegUrl: json['jpeg_url'],
      jpegWidth: json['jpeg_width'],
      jpegHeight: json['jpeg_height'],
      jpegFileSize: json['jpeg_file_size'],
      rating: json['rating'],
      isRatingLocked: json['is_rating_locked'],
      hasChildren: json['has_children'],
      parentId: json['parent_id'],
      status: json['status'],
      isPending: json['is_pending'],
      width: json['width'],
      height: json['height'],
      isHeld: json['is_held'],
      framesPendingString: json['frames_pending_string'],
      framesPending: json['frames_pending'],
      framesString: json['frames_string'],
      frames: json['frames'],
      isNoteLocked: json['is_note_locked'],
      lastNotedAt: json['last_noted_at'],
      lastCommentedAt: json['last_commented_at'],
    );
  }

  final int? id;
  final String? tags;
  final int? createdAt;
  final int? updatedAt;
  final int? creatorId;
  final int? approverId;
  final String? author;
  final int? change;
  final String? source;
  final int? score;
  final String? md5;
  final int? fileSize;
  final String? fileExt;
  final String? fileUrl;
  final bool? isShownInIndex;
  final String? previewUrl;
  final int? previewWidth;
  final int? previewHeight;
  final int? actualPreviewWidth;
  final int? actualPreviewHeight;
  final String? sampleUrl;
  final int? sampleWidth;
  final int? sampleHeight;
  final int? sampleFileSize;
  final String? jpegUrl;
  final int? jpegWidth;
  final int? jpegHeight;
  final int? jpegFileSize;
  final String? rating;
  final bool? isRatingLocked;
  final bool? hasChildren;
  final int? parentId;
  final String? status;
  final bool? isPending;
  final int? width;
  final int? height;
  final bool? isHeld;
  final String? framesPendingString;
  final List<dynamic>? framesPending;
  final String? framesString;
  final List<dynamic>? frames;
  final bool? isNoteLocked;
  final int? lastNotedAt;
  final int? lastCommentedAt;

  @override
  List<Object?> get props => [id];
}
