// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';
import 'post_variant.dart';

class DanbooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  const DanbooruPost({
    required this.id,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
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
  });

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
  List<Object?> get props => [id];
}

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
    const censoredTags = ['loli', 'shota'];
    final tagSet = tags.toSet();

    return censoredTags.any(tagSet.contains);
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
        tags: tags ?? this.tags,
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

extension DanbooruPostVideoX on DanbooruPost {
  bool get hasSound => metaTags.contains('sound');
  String get videoUrl => sampleImageUrl;
  String get videoThumbnailUrl => url720x720;
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
