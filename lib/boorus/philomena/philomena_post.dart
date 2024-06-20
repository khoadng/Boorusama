// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class PhilomenaPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        TagListCheckMixin
    implements Post {
  PhilomenaPost({
    required this.id,
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
    required this.source,
    required this.score,
    required this.duration,
    required this.fileSize,
    required this.format,
    required this.hasSound,
    required this.height,
    required this.md5,
    required this.videoThumbnailUrl,
    required this.videoUrl,
    required this.width,
    required this.description,
    required this.commentCount,
    required this.favCount,
    required this.upvotes,
    required this.downvotes,
    required this.representation,
    required this.uploaderId,
    required this.metadata,
  });

  @override
  final int id;
  @override
  final DateTime? createdAt;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final Set<String> tags;
  @override
  final Rating rating;
  @override
  bool get hasComment => commentCount > 0;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;
  @override
  final int? parentId;
  @override
  final PostSource source;
  @override
  final int score;
  @override
  final int downvotes;
  @override
  final double duration;
  @override
  final int fileSize;
  @override
  final String format;
  @override
  final bool? hasSound;
  @override
  final double height;
  @override
  final String md5;
  @override
  final String videoThumbnailUrl;
  @override
  final String videoUrl;
  @override
  final double width;

  @override
  String getLink(String baseUrl) =>
      baseUrl.endsWith('/') ? '${baseUrl}images/$id' : '$baseUrl/images/$id';

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  List<Object?> get props => [id];

  @override
  Set<String>? get artistTags => _findArtistFromTags(tags);

  @override
  Set<String>? get characterTags => null;

  @override
  Set<String>? get copyrightTags => null;

  final String description;
  final int commentCount;
  final int favCount;
  final int upvotes;

  final PhilomenaRepresentation representation;

  @override
  final int? uploaderId;

  @override
  final PostMetadata? metadata;
}

Set<String>? _findArtistFromTags(Set<String> tags) {
  const metaTag = 'artist:';
  final artistTag = tags.firstWhereOrNull((e) => e.startsWith(metaTag));
  return artistTag != null ? {artistTag.substring(metaTag.length)} : null;
}

class PhilomenaRepresentation extends Equatable {
  final String full;
  final String large;
  final String medium;
  final String small;
  final String tall;
  final String thumb;
  final String thumbSmall;
  final String thumbTiny;

  const PhilomenaRepresentation({
    required this.full,
    required this.large,
    required this.medium,
    required this.small,
    required this.tall,
    required this.thumb,
    required this.thumbSmall,
    required this.thumbTiny,
  });

  @override
  List<Object> get props => [
        full,
        large,
        medium,
        small,
        tall,
        thumb,
        thumbSmall,
        thumbTiny,
      ];
}

enum PhilomenaPostQualityType {
  full,
  large,
  medium,
  small,
  tall,
  thumb,
  thumbSmall,
  thumbTiny,
}

extension PhilomenaPostQualityTypeX on PhilomenaPostQualityType {
  String stringify() => switch (this) {
        PhilomenaPostQualityType.full => 'full',
        PhilomenaPostQualityType.large => 'large',
        PhilomenaPostQualityType.medium => 'medium',
        PhilomenaPostQualityType.small => 'small',
        PhilomenaPostQualityType.tall => 'tall',
        PhilomenaPostQualityType.thumb => 'thumb',
        PhilomenaPostQualityType.thumbSmall => 'thumbSmall',
        PhilomenaPostQualityType.thumbTiny => 'thumbTiny'
      };
}

PhilomenaPostQualityType? stringToPhilomenaPostQualityType(String? value) =>
    switch (value) {
      'full' => PhilomenaPostQualityType.full,
      'large' => PhilomenaPostQualityType.large,
      'medium' => PhilomenaPostQualityType.medium,
      'small' => PhilomenaPostQualityType.small,
      'tall' => PhilomenaPostQualityType.tall,
      'thumb' => PhilomenaPostQualityType.thumb,
      'thumbSmall' => PhilomenaPostQualityType.thumbSmall,
      'thumbTiny' => PhilomenaPostQualityType.thumbTiny,
      _ => null,
    };
