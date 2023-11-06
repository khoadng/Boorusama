// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';
import 'post_variant.dart';

typedef DanbooruPostsOrError = PostsOrErrorCore<DanbooruPost>;

class DanbooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        TagListCheckMixin
    implements Post, DanbooruTagDetails {
  DanbooruPost({
    required this.id,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.copyrightTags,
    required this.characterTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.width,
    required this.height,
    required this.format,
    required this.md5,
    required this.lastCommentAt,
    required this.source,
    required this.createdAt,
    required this.score,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.uploaderId,
    required this.rating,
    required this.fileSize,
    required this.isBanned,
    required this.hasChildren,
    required this.parentId,
    required this.hasLarge,
    required this.duration,
    required this.variants,
  }) : tags = [
          ...artistTags,
          ...copyrightTags,
          ...characterTags,
          ...generalTags,
          ...metaTags,
        ];

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
        width: 1,
        height: 1,
        format: 'png',
        md5: '',
        lastCommentAt: null,
        source: PostSource.none(),
        createdAt: DateTime.now(),
        score: 0,
        upScore: 0,
        downScore: 0,
        favCount: 0,
        uploaderId: 0,
        rating: Rating.explicit,
        fileSize: 0,
        isBanned: false,
        hasChildren: false,
        hasLarge: false,
        parentId: null,
        duration: 0,
        variants: const [],
      );

  @override
  final int id;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final List<String> copyrightTags;
  @override
  final List<String> characterTags;
  @override
  final List<String> artistTags;
  @override
  final List<String> generalTags;
  @override
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
  @override
  final DateTime createdAt;
  @override
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  final int uploaderId;
  @override
  final Rating rating;
  @override
  final int fileSize;
  final bool isBanned;
  final bool hasChildren;
  @override
  final int? parentId;
  final bool hasLarge;
  @override
  final double duration;
  final List<PostVariant> variants;

  @override
  bool get hasComment => lastCommentAt != null;

  bool get hasParent => parentId != null;
  bool get hasBothParentAndChildren => hasChildren && hasParent;
  @override
  bool get hasParentOrChildren => hasChildren || hasParent;

  double get upvotePercent => totalVote > 0 ? upScore / totalVote : 1;
  int get totalVote => upScore + -downScore;
  bool get hasVoter => upScore != 0 || downScore != 0;
  bool get hasFavorite => favCount > 0;

  @override
  int? get downvotes => -downScore;

  @override
  bool? get hasSound => metaTags.contains('sound') ? true : null;
  @override
  String get videoUrl => sampleImageUrl;
  @override
  String get videoThumbnailUrl => url720x720;

  @override
  final PostSource source;

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
  List<Object?> get props => [
        id,
        tags,
        generalTags,
        artistTags,
        characterTags,
        copyrightTags,
        metaTags,
        rating,
      ];
}

const kCensoredTags = ['loli', 'shota'];

extension PostX on DanbooruPost {
  String get url180x180 =>
      variants.firstWhereOrNull((e) => e.is180x180)?.url ?? thumbnailImageUrl;

  String get url360x360 =>
      variants.firstWhereOrNull((e) => e.is360x360)?.url ?? thumbnailImageUrl;

  String get url720x720 =>
      variants.firstWhereOrNull((e) => e.is720x720)?.url ?? thumbnailImageUrl;

  String get urlSample =>
      variants.firstWhereOrNull((e) => e.isSample)?.url ?? sampleImageUrl;

  String get urlOriginal =>
      variants.firstWhereOrNull((e) => e.isOriginal)?.url ?? originalImageUrl;

  bool get hasCensoredTags {
    final tagSet = tags.toSet();

    return kCensoredTags.any(tagSet.contains);
  }

  List<PostDetailTag> extractTagDetails() {
    final p = this;
    return [
      ...p.artistTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.artist.stringify(),
            postId: p.id,
          )),
      ...p.characterTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.character.stringify(),
            postId: p.id,
          )),
      ...p.copyrightTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.copyright.stringify(),
            postId: p.id,
          )),
      ...p.generalTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.general.stringify(),
            postId: p.id,
          )),
      ...p.metaTags.map((e) => PostDetailTag(
            name: e,
            category: TagCategory.meta.stringify(),
            postId: p.id,
          )),
    ];
  }

  List<Tag> extractTags() {
    final tags = <Tag>[];

    for (final t in artistTags) {
      tags.add(Tag(name: t, category: TagCategory.artist, postCount: 0));
    }

    for (final t in copyrightTags) {
      tags.add(Tag(name: t, category: TagCategory.copyright, postCount: 0));
    }

    for (final t in characterTags) {
      tags.add(Tag(name: t, category: TagCategory.character, postCount: 0));
    }

    for (final t in metaTags) {
      tags.add(Tag(name: t, category: TagCategory.meta, postCount: 0));
    }

    for (final t in generalTags) {
      tags.add(Tag(name: t, category: TagCategory.general, postCount: 0));
    }

    return tags;
  }

  DanbooruPost copyWith({
    int? id,
    List<String>? copyrightTags,
    List<String>? characterTags,
    List<String>? artistTags,
    List<String>? generalTags,
    List<String>? metaTags,
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
    PostSource? source,
    int? parentId,
  }) =>
      DanbooruPost(
        id: id ?? this.id,
        thumbnailImageUrl: thumbnailImageUrl,
        sampleImageUrl: sampleImageUrl ?? this.sampleImageUrl,
        originalImageUrl: originalImageUrl ?? this.originalImageUrl,
        copyrightTags: copyrightTags ?? this.copyrightTags,
        characterTags: characterTags ?? this.characterTags,
        artistTags: artistTags ?? this.artistTags,
        generalTags: generalTags ?? this.generalTags,
        metaTags: metaTags ?? this.metaTags,
        width: width,
        height: height,
        format: format ?? this.format,
        md5: md5 ?? this.md5,
        lastCommentAt: lastCommentAt ?? this.lastCommentAt,
        source: source ?? this.source,
        createdAt: createdAt,
        score: score ?? this.score,
        upScore: upScore ?? this.upScore,
        downScore: downScore ?? this.downScore,
        favCount: favCount ?? this.favCount,
        uploaderId: uploaderId,
        rating: rating,
        fileSize: fileSize,
        isBanned: isBanned,
        hasChildren: hasChildren ?? this.hasChildren,
        hasLarge: hasLarge,
        parentId: parentId ?? this.parentId,
        duration: duration,
        variants: variants,
      );
}

extension DanbooruPostImageX on DanbooruPost {
  String thumbnailFromImageQuality(ImageQuality quality) => switch (quality) {
        ImageQuality.low => url360x360,
        ImageQuality.high => url720x720,
        ImageQuality.highest => isVideo ? url720x720 : urlSample,
        ImageQuality.original => urlOriginal,
        ImageQuality.automatic => url720x720
      };

  String thumbnailFromSettings(Settings settings) {
    if (isGif) return urlSample;
    return thumbnailFromImageQuality(settings.imageQuality);
  }
}

abstract interface class DanbooruTagDetails implements TagDetails {
  List<String>? get generalTags;
  List<String>? get metaTags;
  Rating get rating;
}

extension DanbooruTagDetailsX on DanbooruTagDetails {
  List<String> get allTags => [
        ...artistTags ?? [],
        ...characterTags ?? [],
        ...copyrightTags ?? [],
        ...generalTags ?? [],
        ...metaTags ?? [],
      ];
}
