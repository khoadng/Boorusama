// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';
import 'package:boorusama/functional.dart';

class PostMetadata extends Equatable {
  const PostMetadata({
    this.page,
    this.search,
  });
  final int? page;
  final String? search;

  @override
  List<Object?> get props => [page, search];
}

abstract class Post
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin, TagListCheckMixin
    implements TagDetails {
  int get id;
  DateTime? get createdAt;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  @override
  Set<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  int? get parentId;
  PostSource get source;
  int get score;
  int? get downvotes;
  int? get uploaderId;

  PostMetadata? get metadata;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

abstract interface class TagDetails {
  Set<String>? get artistTags;
  Set<String>? get characterTags;
  Set<String>? get copyrightTags;
}

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
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
    required this.source,
    required this.score,
    this.downvotes,
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
    this.uploaderName,
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

  final String? uploaderName;

  @override
  String getLink(String baseUrl);

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  final PostMetadata? metadata;

  @override
  List<Object?> get props => [id];
}

abstract class PostRepository<T extends Post> {
  PostsOrError<T> getPosts(
    String tags,
    int page, {
    int? limit,
  });

  PostsOrError<T> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  });

  TagQueryComposer get tagComposer;
}

class PostResult<T extends Post> extends Equatable {
  const PostResult({
    required this.posts,
    required this.total,
  });

  PostResult.empty()
      : posts = <T>[],
        total = 0;

  PostResult<T> copyWith({
    List<T>? posts,
    int? Function()? total,
  }) =>
      PostResult(
        posts: posts ?? this.posts,
        total: total != null ? total() : this.total,
      );

  final List<T> posts;
  final int? total;

  @override
  List<Object?> get props => [posts, total];
}

extension PostResultX<T extends Post> on List<T> {
  PostResult<T> toResult({
    int? total,
  }) =>
      PostResult(
        posts: this,
        total: total,
      );
}

typedef PostsOrErrorCore<T extends Post>
    = TaskEither<BooruError, PostResult<T>>;

typedef PostsOrError<T extends Post> = PostsOrErrorCore<T>;

typedef PostFutureFetcher<T extends Post> = Future<PostResult<T>> Function(
  List<String> tags,
  int page, {
  int? limit,
});

typedef PostFutureControllerFetcher<T extends Post> = Future<PostResult<T>>
    Function(
  SelectedTagController controller,
  int page, {
  int? limit,
});

mixin NoTagDetailsMixin implements Post {
  @override
  Set<String>? get artistTags => null;
  @override
  Set<String>? get characterTags => null;
  @override
  Set<String>? get copyrightTags => null;
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  bool get hasNoImage =>
      thumbnailImageUrl.isEmpty &&
      sampleImageUrl.isEmpty &&
      originalImageUrl.isEmpty;

  bool get hasParent => parentId != null && parentId! > 0;
}

extension PostX on Post {
  List<Tag> extractTags() => tags
      .map((e) => Tag.noCount(
            name: e,
            category: TagCategory.general(),
          ))
      .toList();

  TagFilterData extractTagFilterData() => TagFilterData(
        tags: tags,
        rating: rating,
        score: score,
        downvotes: downvotes,
        uploaderId: uploaderId,
        source: switch (source) {
          final WebSource w => w.url,
          final NonWebSource nw => nw.value,
          _ => null,
        },
        id: id,
      );

  bool containsTagPattern(List<TagExpression> pattern) =>
      checkIfTagsContainsTagExpression(
        extractTagFilterData(),
        pattern,
      );

  String get relationshipQuery => hasParent ? 'parent:$parentId' : 'parent:$id';
}

enum GeneralPostQualityType {
  preview,
  sample,
  original,
}

extension GeneralPostQualityTypeX on GeneralPostQualityType {
  String stringify() => switch (this) {
        GeneralPostQualityType.preview => 'preview',
        GeneralPostQualityType.sample => 'sample',
        GeneralPostQualityType.original => 'original',
      };
}

GeneralPostQualityType stringToGeneralPostQualityType(String? value) =>
    switch (value) {
      'preview' => GeneralPostQualityType.preview,
      'sample' => GeneralPostQualityType.sample,
      'original' => GeneralPostQualityType.original,
      _ => GeneralPostQualityType.sample,
    };

mixin TagListCheckMixin {
  Set<String> get tags;

  bool get isAI => tags.any((e) => _kAiTags.contains(e.toLowerCase()));
}

const _kAiTags = {
  'ai-generated',
  'ai_generated',
  'ai-created',
  'ai art',
};

extension PostsX on Iterable<Post> {
  Map<String, int> extractTagsWithoutCount() {
    final tagCounts = <String, int>{};

    for (final item in this) {
      for (final tag in item.tags) {
        if (tagCounts.containsKey(tag)) {
          tagCounts[tag] = tagCounts[tag]! + 1;
        } else {
          tagCounts[tag] = 1;
        }
      }
    }

    return tagCounts;
  }
}

Set<String> splitRawTagString(String? rawTagString) {
  if (rawTagString == null) return {};
  if (rawTagString.isEmpty) return {};

  return rawTagString.split(' ').where((element) => element.isNotEmpty).toSet();
}

extension TagStringSplitter on String? {
  Set<String> splitTagString() => splitRawTagString(this);
}
