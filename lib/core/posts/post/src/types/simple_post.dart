// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../rating/types.dart';
import '../../../sources/types.dart';
import '../mixins/image_info_mixin.dart';
import '../mixins/media_info_mixin.dart';
import '../mixins/post_mixin.dart';
import '../mixins/translatable_mixin.dart';
import '../mixins/video_info_mixin.dart';
import 'post.dart';

abstract class SimplePost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin,
        TagListCheckMixin
    implements Post {
  SimplePost({
    required this.id,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
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
    required this.uploaderId,
    required this.metadata,
    this.createdAt,
    this.parentId,
    this.downvotes,
    this.uploaderName,
    this.status,
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
  final bool hasComment;
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
  final int? downvotes;
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
  final int? uploaderId;

  @override
  final String? uploaderName;

  @override
  final PostMetadata? metadata;

  @override
  final PostStatus? status;

  @override
  List<Object?> get props => [id];
}

mixin NoTagDetailsMixin implements Post {
  @override
  Set<String>? get artistTags => null;
  @override
  Set<String>? get characterTags => null;
  @override
  Set<String>? get copyrightTags => null;
}

class DemoPost extends SimplePost {
  DemoPost()
    : super(
        id: 123,
        thumbnailImageUrl: '',
        sampleImageUrl: '',
        originalImageUrl: '',
        tags: {
          'artist1',
          'artist2',
          'character1',
          'character2',
          'copy1',
          'copy2',
          'general1',
          'general2',
          'meta1',
          'meta2',
        },
        rating: Rating.general,
        hasComment: false,
        isTranslated: false,
        hasParentOrChildren: false,
        source: PostSource.none(),
        score: 56,
        duration: 0,
        fileSize: 1024 * 1024 * 5,
        format: '.jpg',
        hasSound: null,
        height: 1080,
        md5: '',
        videoThumbnailUrl: '',
        videoUrl: '',
        width: 1920,
        uploaderId: null,
        metadata: null,
        createdAt: null,
        parentId: null,
        downvotes: null,
        uploaderName: null,
      );
}
