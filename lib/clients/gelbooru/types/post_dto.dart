// Package imports:
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

class PostDto {

  PostDto({
    this.previewUrl,
    this.sampleUrl,
    this.fileUrl,
    this.directory,
    this.hash,
    this.width,
    this.height,
    this.id,
    this.image,
    this.change,
    this.owner,
    this.parentId,
    this.rating,
    this.sample,
    this.sampleHeight,
    this.sampleWidth,
    this.score,
    this.tags,
    this.source,
    this.status,
    this.hasNotes,
    this.commentCount,
    this.createdAt,
    this.md5,
    this.title,
    this.hasComments,
    this.postLocked,
    this.hasChildren,
    this.creatorId,
  });

  factory PostDto.fromJson(Map<String, dynamic> json, String baseUrl) {
    var previewUrl = '';
    var sampleUrl = '';
    var fileUrl = '';

    if (json['preview_url'] != null) {
      previewUrl = json['preview_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      previewUrl =
          '$baseUrl/thumbnails/${json['directory']}/thumbnail_${json['image']}';
      // Change the extension to jpg
      previewUrl = previewUrl.replaceAll(
        path.extension(previewUrl),
        '.jpg',
      );
    } else {
      previewUrl = '';
    }

    if (json['file_url'] != null) {
      fileUrl = json['file_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      fileUrl = '$baseUrl/images/${json['directory']}/${json['image']}';
    } else {
      fileUrl = '';
    }

    if (json['sample_url'] != null) {
      sampleUrl = json['sample_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      if (json['sample'] != null && json['sample'] == true) {
        sampleUrl =
            '$baseUrl/samples/${json['directory']}/sample_${json['image']}';
        // Change the extension to jpg
        sampleUrl = sampleUrl.replaceAll(
          path.extension(sampleUrl),
          '.jpg',
        );
      } else {
        sampleUrl = fileUrl;
      }
    } else {
      sampleUrl = '';
    }

    return PostDto(
      previewUrl: previewUrl,
      sampleUrl: sampleUrl,
      fileUrl: fileUrl,
      directory: json['directory']?.toString(),
      hash: json['hash'],
      width: json['width'],
      height: json['height'],
      id: json['id'],
      image: json['image'],
      change: json['change'],
      owner: json['owner'],
      parentId: json['parent_id'],
      rating: json['rating'],
      sample: _parseBool(json['sample']),
      sampleHeight: json['sample_height'],
      sampleWidth: json['sample_width'],
      score: json['score'],
      tags: json['tags'],
      source: json['source'],
      status: json['status'],
      hasNotes: _parseBool(json['has_notes']),
      commentCount: json['comment_count'],
      createdAt: json['created_at'],
      md5: json['md5'] ?? json['hash'],
      title: json['title'],
      hasComments: _parseHasComment(json),
      postLocked: _parseBool(json['post_locked']),
      hasChildren: _parseBool(json['has_children']),
      creatorId: json['creator_id'],
    );
  }
  final String? previewUrl;
  final String? sampleUrl;
  final String? fileUrl;
  final String? directory;
  final String? hash;
  final int? width;
  final int? height;
  final int? id;
  final String? image;
  final int? change;
  final String? owner;
  final int? parentId;
  final String? rating;
  final bool? sample;
  final int? sampleHeight;
  final int? sampleWidth;
  final int? score;
  final String? tags;
  final String? source;
  final String? status;
  final bool? hasNotes;
  final int? commentCount;
  final String? createdAt;
  final String? md5;
  final String? title;
  final bool? hasComments;
  final bool? postLocked;
  final bool? hasChildren;
  final int? creatorId;

  @override
  String toString() => '$id: $fileUrl';
}

bool? _parseBool(dynamic value) => switch (value) {
      int i => i > 0 ? true : false,
      bool b => b,
      String s => bool.tryParse(s),
      _ => null,
    };

bool _parseHasComment(Map<String, dynamic> data) {
  if (data['has_comments'] != null) {
    final value = data['has_comments'];
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value > 0;
    } else if (value is String) {
      return bool.tryParse(value) ?? false;
    } else {
      return false;
    }
  } else if (data['comment_count'] != null) {
    final value = data['comment_count'];
    if (value is int) {
      return value > 0;
    } else if (value is String) {
      final intValue = int.tryParse(value);
      return intValue != null ? intValue > 0 : false;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

class PostFavoriteDto extends Equatable {
  const PostFavoriteDto({
    required this.id,
    required this.tags,
    required this.previewUrl,
  });

  final int? id;
  final String? tags;
  final String? previewUrl;

  @override
  List<Object?> get props => [id, tags, previewUrl];
}
