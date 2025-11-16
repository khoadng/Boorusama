// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'status.dart';

export 'status.dart';

class E621Post extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  E621Post({
    required this.id,
    required this.source,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    required this.format,
    required this.width,
    required this.height,
    required this.md5,
    required this.fileSize,
    required this.score,
    required this.createdAt,
    required this.duration,
    required this.characterTags,
    required this.copyrightTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.speciesTags,
    required this.invalidTags,
    required this.loreTags,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.isFavorited,
    required this.sources,
    required this.description,
    required this.videoUrl,
    required this.parentId,
    required this.uploaderId,
    required this.uploaderName,
    required this.metadata,
    required this.videoVariants,
    required this.status,
  });

  @override
  final int id;
  @override
  Set<String> get tags => {
    ...characterTags,
    ...artistTags,
    ...generalTags,
    ...copyrightTags,
    ...metaTags,
    ...speciesTags,
    ...invalidTags,
    ...loreTags,
  };
  @override
  final Set<String> copyrightTags;
  @override
  final Set<String> characterTags;
  @override
  final Set<String> artistTags;
  final Set<String> generalTags;
  final Set<String> metaTags;
  final Set<String> loreTags;
  final Set<String> invalidTags;
  final Set<String> speciesTags;
  @override
  final PostSource source;
  final List<PostSource> sources;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final Rating rating;
  @override
  final bool hasComment;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;

  @override
  final String format;
  @override
  final double width;
  @override
  final double height;
  @override
  final String md5;
  @override
  final int fileSize;
  @override
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  final bool isFavorited;
  final String description;

  @override
  int? get downvotes => -downScore;

  @override
  bool? get hasSound => metaTags.contains('sound') ? true : null;
  @override
  final String videoUrl;
  @override
  String get videoThumbnailUrl => sampleImageUrl;

  @override
  List<Object?> get props => [id];

  @override
  final double duration;

  @override
  final DateTime createdAt;

  @override
  final int? parentId;

  @override
  final int? uploaderId;

  @override
  final String? uploaderName;

  @override
  final PostMetadata? metadata;

  @override
  final E621PostStatus? status;

  final Map<E621VideoVariantType, E621VideoVariant> videoVariants;
}

class E621VideoVariant extends Equatable {
  const E621VideoVariant({
    required this.type,
    required this.url,
    required this.size,
    required this.width,
    required this.height,
    required this.codec,
    required this.fps,
  });

  final E621VideoVariantType type;
  final String url;
  final int size;
  final int width;
  final int height;
  final String codec;
  final double fps;

  String? get format => url.split('.').lastOrNull;

  E621VideoVariant copyWith({
    E621VideoVariantType? type,
  }) => E621VideoVariant(
    type: type ?? this.type,
    url: url,
    size: size,
    width: width,
    height: height,
    codec: codec,
    fps: fps,
  );

  @override
  List<Object?> get props => [type, url, size, width, height, codec, fps];
}

enum E621VideoVariantType {
  original,
  sample,
  v720p,
  v480p;

  static E621VideoVariantType? tryParse(String? value) => switch (value) {
    'original' => original,
    'sample' => sample,
    '720p' => v720p,
    '480p' => v480p,
    _ => null,
  };

  String get value => switch (this) {
    original => 'original',
    sample => 'sample',
    v720p => '720p',
    v480p => '480p',
  };

  String getLabel(BuildContext context) => switch (this) {
    original => context.t.video_player.video_qualities.original,
    sample => context.t.video_player.video_qualities.sample,
    v720p => '720p',
    v480p => '480p',
  };
}

class E621MediaUrlResolver extends DefaultMediaUrlResolver {
  E621MediaUrlResolver({
    required super.imageQuality,
  });

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => switch (post) {
    final E621Post p =>
      switch (E621VideoVariantType.tryParse(config.videoQuality)) {
            E621VideoVariantType.original =>
              p.videoVariants[E621VideoVariantType.original]?.url,
            E621VideoVariantType.sample =>
              p.videoVariants[E621VideoVariantType.sample]?.url,
            E621VideoVariantType.v720p =>
              p.videoVariants[E621VideoVariantType.v720p]?.url,
            E621VideoVariantType.v480p =>
              p.videoVariants[E621VideoVariantType.v480p]?.url,
            null => p.videoVariants[E621VideoVariantType.v720p]?.url,
          } ??
          post.videoUrl,
    _ => post.videoUrl,
  };
}
