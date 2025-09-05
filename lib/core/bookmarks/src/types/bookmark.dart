// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/path.dart';
import '../../../posts/post/post.dart';

class Bookmark extends Equatable with ImageInfoMixin, TagListCheckMixin {
  Bookmark({
    required this.id,
    required this.booruId,
    required this.createdAt,
    required this.updatedAt,
    required String thumbnailUrl,
    required String sampleUrl,
    required String originalUrl,
    required this.sourceUrl,
    required this.width,
    required this.height,
    required this.md5,
    required this.tags,
    required this.realSourceUrl,
    required this.format,
    required ImageUrlResolver imageUrlResolver,
    required this.postId,
    required this.metadata,
  }) : _originalUrl = originalUrl,
       _sampleUrl = sampleUrl,
       _thumbnailUrl = thumbnailUrl,
       _resolver = imageUrlResolver;

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    required ImageUrlResolver imageUrlResolver,
  }) {
    return Bookmark(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String,
      sampleUrl: json['sampleUrl'] as String,
      originalUrl: json['originalUrl'] as String,
      sourceUrl: json['sourceUrl'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      md5: json['md5'] as String,
      tags: _parseTags(json['tags']),
      realSourceUrl: json['realSourceUrl'] as String?,
      format: json['format'] as String?,
      imageUrlResolver: imageUrlResolver,
      postId: json['postId'] as int?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  final String _originalUrl;
  final String _sampleUrl;
  final String _thumbnailUrl;
  final ImageUrlResolver _resolver;

  final int id;
  final int booruId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sourceUrl;
  @override
  final double width;
  @override
  final double height;
  final String md5;
  @override
  final Set<String> tags;
  final String? realSourceUrl;
  final String? format;
  final int? postId;
  final Map<String, String> metadata;

  static Map<String, String> toMetadata(PostMetadata? metadata) {
    if (metadata == null) {
      return <String, String>{};
    }

    final map = <String, String>{};

    if (metadata.page != null) {
      map['page'] = metadata.page.toString();
    }
    if (metadata.limit != null) {
      map['limit'] = metadata.limit.toString();
    }
    if (metadata.search != null) {
      map['search'] = metadata.search.toString();
    }

    return map;
  }

  int? get metadataPage =>
      metadata['page'] != null ? int.tryParse(metadata['page']!) : null;
  int? get metadataLimit =>
      metadata['limit'] != null ? int.tryParse(metadata['limit']!) : null;
  String? get metadataSearch => metadata['search'];

  String get originalUrl => _resolver.resolveImageUrl(_originalUrl);
  String get sampleUrl => _resolver.resolvePreviewUrl(_sampleUrl);
  String get thumbnailUrl => _resolver.resolveThumbnailUrl(_thumbnailUrl);

  bool get isVideo {
    final ext = extension(originalUrl);
    final effectiveFormat = ext.isEmpty ? format : ext;

    if (effectiveFormat == null) return false;

    return isFormatVideo(effectiveFormat);
  }

  BookmarkUniqueId get uniqueId => BookmarkUniqueId(
    booruId: booruId,
    url: originalUrl,
  );

  static var empty = Bookmark(
    id: -1,
    booruId: -10,
    createdAt: DateTime(1),
    updatedAt: DateTime(1),
    thumbnailUrl: '',
    sampleUrl: '',
    originalUrl: '',
    sourceUrl: '',
    width: -1,
    height: -1,
    md5: '',
    tags: const {},
    realSourceUrl: null,
    format: null,
    imageUrlResolver: const DefaultImageUrlResolver(),
    postId: null,
    metadata: const {},
  );

  @override
  List<Object?> get props => [
    id,
    booruId,
    createdAt,
    updatedAt,
    thumbnailUrl,
    sampleUrl,
    originalUrl,
    sourceUrl,
    width,
    height,
    md5,
    tags,
    realSourceUrl,
    format,
    postId,
    metadata,
  ];

  Bookmark copyWith({
    int? id,
    // int? booruId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailUrl,
    String? sampleUrl,
    String? originalUrl,
    String? sourceUrl,
    double? width,
    double? height,
    String? md5,
    Set<String>? tags,
    String? Function()? realSourceUrl,
    String? Function()? format,
    int? Function()? postId,
    Map<String, String>? metadata,
    ImageUrlResolver? imageUrlResolver,
  }) {
    return Bookmark(
      id: id ?? this.id,
      booruId: booruId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sampleUrl: sampleUrl ?? this.sampleUrl,
      originalUrl: originalUrl ?? this.originalUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      md5: md5 ?? this.md5,
      tags: tags ?? this.tags,
      realSourceUrl: realSourceUrl != null
          ? realSourceUrl()
          : this.realSourceUrl,
      format: format != null ? format() : this.format,
      imageUrlResolver: imageUrlResolver ?? _resolver,
      postId: postId != null ? postId() : this.postId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booruId': booruId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailUrl': _thumbnailUrl,
      'sampleUrl': _sampleUrl,
      'originalUrl': _originalUrl,
      'sourceUrl': sourceUrl,
      'width': width,
      'height': height,
      'md5': md5,
      'tags': tags.toList(),
      'realSourceUrl': realSourceUrl,
      'format': format,
      'postId': postId,
      'metadata': Map<String, String>.from(metadata),
    };
  }
}

Set<String> _parseTags(dynamic tags) => switch (tags) {
  final String s => tryDecodeJson(s).fold(
    (l) => const {},
    (r) => _parseJsonTags(r),
  ),
  final List l => l.map((e) => e.toString()).toSet(),
  _ => const {},
};

Set<String> _parseJsonTags(dynamic tags) => switch (tags) {
  final List l => l.map((e) => e.toString()).toSet(),
  _ => const {},
};

enum BookmarkGetError {
  nullField,
  databaseClosed,
  unknown,
}

typedef BookmarksOrError = TaskEither<BookmarkGetError, List<Bookmark>>;

class BookmarkUniqueId extends Equatable {
  const BookmarkUniqueId({
    required this.booruId,
    required this.url,
  });

  BookmarkUniqueId.fromPost(Post post, this.booruId)
    : url = post.originalImageUrl;

  final int booruId;
  final String url;

  @override
  List<Object?> get props => [booruId, url];
}
