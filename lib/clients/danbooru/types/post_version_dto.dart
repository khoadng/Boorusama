// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';

class PostVersionDto extends Equatable {

  const PostVersionDto({
    this.id,
    this.postId,
    this.tags,
    this.addedTags,
    this.removedTags,
    this.updaterId,
    this.updatedAt,
    this.rating,
    this.ratingChanged,
    this.parentId,
    this.parentChanged,
    this.source,
    this.sourceChanged,
    this.version,
    this.obsoleteAddedTags,
    this.obsoleteRemovedTags,
    this.unchangedTags,
    this.updater,
  });

  factory PostVersionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PostVersionDto();

    return PostVersionDto(
      id: json['id'],
      postId: json['post_id'],
      tags: json['tags'],
      addedTags: json['added_tags'] != null
          ? List<String>.from(json['added_tags'])
          : null,
      removedTags: json['removed_tags'] != null
          ? List<String>.from(json['removed_tags'])
          : null,
      updaterId: json['updater_id'],
      updatedAt: json['updated_at'],
      rating: json['rating'],
      ratingChanged: json['rating_changed'],
      parentId: json['parent_id'],
      parentChanged: json['parent_changed'],
      source: json['source'],
      sourceChanged: json['source_changed'],
      version: json['version'],
      obsoleteAddedTags: json['obsolete_added_tags'],
      obsoleteRemovedTags: json['obsolete_removed_tags'],
      unchangedTags: json['unchanged_tags'],
      updater:
          json['updater'] != null ? UserDto.fromJson(json['updater']) : null,
    );
  }
  final int? id;
  final int? postId;
  final String? tags;
  final List<String>? addedTags;
  final List<String>? removedTags;
  final int? updaterId;
  final String? updatedAt;
  final String? rating;
  final bool? ratingChanged;
  final int? parentId;
  final bool? parentChanged;
  final String? source;
  final bool? sourceChanged;
  final int? version;
  final String? obsoleteAddedTags;
  final String? obsoleteRemovedTags;
  final String? unchangedTags;

  final UserDto? updater;

  @override
  List<Object?> get props => [
        id,
        postId,
        tags,
        addedTags,
        removedTags,
        updaterId,
        updatedAt,
        rating,
        ratingChanged,
        parentId,
        parentChanged,
        source,
        sourceChanged,
        version,
        obsoleteAddedTags,
        obsoleteRemovedTags,
        unchangedTags,
        updater,
      ];
}
