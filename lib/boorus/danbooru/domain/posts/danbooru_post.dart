// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/image.dart';
import 'package:boorusama/core/domain/posts/media_info_mixin.dart';
import 'package:boorusama/core/domain/posts/post.dart' as base;
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/domain/posts/source_mixin.dart';
import 'package:boorusama/core/domain/posts/translatable_mixin.dart';
import 'package:boorusama/core/domain/tags.dart';

const pixivLinkUrl = 'https://www.pixiv.net/en/artworks/';
const censoredTags = ['loli', 'shota'];

class DanbooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, SourceMixin
    implements base.Post {
  const DanbooruPost({
    required this.id,
    required String thumbnailImageUrl,
    required String sampleImageUrl,
    required this.originalImageUrl,
    required this.copyrightTags,
    required this.characterTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.tags,
    required this.width,
    required this.height,
    required this.format,
    required this.md5,
    required this.lastCommentAt,
    required String? source,
    required this.createdAt,
    required this.score,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.uploaderId,
    required this.rating,
    required this.fileSize,
    required this.pixivId,
    required this.isBanned,
    required this.hasChildren,
    required this.parentId,
    required this.hasLarge,
  })  : _source = source,
        _sampleImageUrl = sampleImageUrl,
        _thumbnailImageUrl = thumbnailImageUrl;

  factory DanbooruPost.empty() => DanbooruPost(
        id: 0,
        thumbnailImageUrl: '',
        sampleImageUrl: '',
        originalImageUrl: '',
        copyrightTags: const [],
        characterTags: const [],
        artistTags: const [],
        generalTags: const [],
        metaTags: const [],
        tags: const [],
        width: 1,
        height: 1,
        format: 'png',
        md5: '',
        lastCommentAt: null,
        source: null,
        createdAt: DateTime.now(),
        score: 0,
        upScore: 0,
        downScore: 0,
        favCount: 0,
        uploaderId: 0,
        rating: Rating.explicit,
        fileSize: 0,
        pixivId: null,
        isBanned: false,
        hasChildren: false,
        hasLarge: false,
        parentId: null,
      );

  final String _thumbnailImageUrl;
  final String _sampleImageUrl;

  @override
  final int id;
  @override
  String get thumbnailImageUrl => _thumbnailImageUrl;
  @override
  String get sampleImageUrl {
    if (isAnimated) return _sampleImageUrl;

    return _thumbnailImageUrl.isNotEmpty ? _sampleImageUrl : _thumbnailImageUrl;
  }

  @override
  String get sampleLargeImageUrl => _sampleImageUrl;

  @override
  final String originalImageUrl;
  final List<String> copyrightTags;
  final List<String> characterTags;
  final List<String> artistTags;
  final List<String> generalTags;
  final List<String> metaTags;
  @override
  final List<String> tags;
  @override
  final double width;
  @override
  final double height;
  @override
  final String format;
  @override
  final String md5;
  final DateTime? lastCommentAt;
  final String? _source;
  final DateTime createdAt;
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  final int uploaderId;
  @override
  final Rating rating;
  @override
  final int fileSize;
  final int? pixivId;
  final bool isBanned;
  final bool hasChildren;
  final int? parentId;
  final bool hasLarge;

  DanbooruPost copyWith({
    int? id,
    List<String>? copyrightTags,
    List<String>? characterTags,
    List<String>? artistTags,
    List<String>? generalTags,
    List<String>? metaTags,
    List<String>? tags,
    String? format,
    String? md5,
    DateTime? lastCommentAt,
    String? sampleImageUrl,
    String? originalImageUrl,
    int? upScore,
    int? downScore,
    int? score,
    int? favCount,
    bool? hasChildren,
    int? pixivId,
    String? source,
    int? parentId,
  }) =>
      DanbooruPost(
        id: id ?? this.id,
        thumbnailImageUrl: _thumbnailImageUrl,
        sampleImageUrl: sampleImageUrl ?? _sampleImageUrl,
        originalImageUrl: originalImageUrl ?? this.originalImageUrl,
        copyrightTags: copyrightTags ?? this.copyrightTags,
        characterTags: characterTags ?? this.characterTags,
        artistTags: artistTags ?? this.artistTags,
        generalTags: generalTags ?? this.generalTags,
        metaTags: metaTags ?? this.metaTags,
        tags: tags ?? this.tags,
        width: width,
        height: height,
        format: format ?? this.format,
        md5: md5 ?? this.md5,
        lastCommentAt: lastCommentAt ?? this.lastCommentAt,
        source: source ?? _source,
        createdAt: createdAt,
        score: score ?? this.score,
        upScore: upScore ?? this.upScore,
        downScore: downScore ?? this.downScore,
        favCount: favCount ?? this.favCount,
        uploaderId: uploaderId,
        rating: rating,
        fileSize: fileSize,
        pixivId: pixivId ?? this.pixivId,
        isBanned: isBanned,
        hasChildren: hasChildren ?? this.hasChildren,
        hasLarge: hasLarge,
        parentId: parentId ?? this.parentId,
      );

  @override
  bool get hasComment => lastCommentAt != null;

  @override
  String get downloadUrl => isVideo ? sampleImageUrl : originalImageUrl;

  bool get hasParent => parentId != null;
  bool get hasBothParentAndChildren => hasChildren && hasParent;
  @override
  bool get hasParentOrChildren => hasChildren || hasParent;

  double get upvotePercent => totalVote > 0 ? upScore / totalVote : 1;
  int get totalVote => upScore + -downScore;
  bool get hasVoter => upScore != 0 || downScore != 0;
  bool get hasFavorite => favCount > 0;

  @override
  String? get source => pixivId == null ? _source : '$pixivLinkUrl$pixivId';

  bool get hasCensoredTags {
    final tagSet = tags.toSet();

    return censoredTags.any(tagSet.contains);
  }

  bool get viewable => [
        thumbnailImageUrl,
        sampleImageUrl,
        originalImageUrl,
        md5,
      ].every((e) => e != '');

  @override
  String getLink(String baseUrl) =>
      baseUrl.endsWith('/') ? '${baseUrl}posts/$id' : '$baseUrl/posts/$id';

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  List<Object?> get props => [id];
}

bool isPostValid(DanbooruPost post) => post.id != 0 && post.viewable;

extension PostX on DanbooruPost {
  List<Tag> extractTags() {
    final tags = <Tag>[];

    for (final t in artistTags) {
      tags.add(Tag(name: t, category: TagCategory.artist, postCount: 0));
    }

    for (final t in copyrightTags) {
      tags.add(Tag(name: t, category: TagCategory.copyright, postCount: 0));
    }

    for (final t in characterTags) {
      tags.add(Tag(name: t, category: TagCategory.charater, postCount: 0));
    }

    for (final t in metaTags) {
      tags.add(Tag(name: t, category: TagCategory.meta, postCount: 0));
    }

    for (final t in generalTags) {
      tags.add(Tag(name: t, category: TagCategory.general, postCount: 0));
    }

    return tags;
  }
}
