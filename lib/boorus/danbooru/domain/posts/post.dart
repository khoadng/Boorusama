// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.previewImageUrl,
    required this.normalImageUrl,
    required this.fullImageUrl,
    required this.copyrightTags,
    required this.characterTags,
    required this.artistTags,
    required this.generalTags,
    required this.tags,
    required this.width,
    required this.height,
    required this.format,
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
    required this.pixivId,
    required this.isBanned,
    required this.hasChildren,
    required this.hasParent,
    this.parentId,
    required this.hasLarge,
  });

  factory Post.empty() => Post(
        id: 0,
        previewImageUrl: '',
        normalImageUrl: '',
        fullImageUrl: '',
        copyrightTags: const [],
        characterTags: const [],
        artistTags: const [],
        generalTags: const [],
        tags: const [],
        width: 1,
        height: 1,
        format: 'png',
        lastCommentAt: null,
        source: ImageSource('', null),
        createdAt: DateTime.now(),
        score: 0,
        upScore: 0,
        downScore: 0,
        favCount: 0,
        uploaderId: 0,
        rating: Rating.explicit,
        fileSize: 0,
        pixivId: 0,
        isBanned: false,
        hasChildren: false,
        hasParent: false,
        hasLarge: false,
      );

  factory Post.banned({
    required DateTime createdAt,
    required int uploaderId,
    required int score,
    required ImageSource source,
    required DateTime? lastCommentAt,
    required Rating rating,
    required double imageWidth,
    required double imageHeight,
    required List<String> tags,
    required int favCount,
    required String fileExt,
    required int fileSize,
    required int upScore,
    required int downScore,
    required bool isBanned,
    required int? pixivId,
    required List<String> generalTags,
    required List<String> characterTags,
    required List<String> copyrightTags,
    required List<String> artistTags,
    required bool hasChildren,
    required bool hasParent,
    required bool hasLarge,
    int? parentId,
  }) =>
      Post(
        id: -1,
        previewImageUrl: '',
        normalImageUrl: '',
        fullImageUrl: '',
        copyrightTags: copyrightTags,
        characterTags: characterTags,
        artistTags: artistTags,
        generalTags: generalTags,
        tags: tags,
        width: imageWidth,
        height: imageHeight,
        format: fileExt,
        lastCommentAt: lastCommentAt,
        source: source,
        createdAt: createdAt,
        score: score,
        upScore: upScore,
        downScore: downScore,
        favCount: favCount,
        uploaderId: uploaderId,
        rating: rating,
        fileSize: fileSize,
        pixivId: pixivId,
        isBanned: isBanned,
        hasChildren: hasChildren,
        hasParent: hasParent,
        parentId: parentId,
        hasLarge: hasLarge,
      );
  final int id;
  final String previewImageUrl;
  final String normalImageUrl;
  final String fullImageUrl;
  final List<String> copyrightTags;
  final List<String> characterTags;
  final List<String> artistTags;
  final List<String> generalTags;
  final List<String> tags;
  final double width;
  final double height;
  final String format;
  final DateTime? lastCommentAt;
  final ImageSource source;
  final DateTime createdAt;
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  final int uploaderId;
  final Rating rating;
  final int fileSize;
  final int? pixivId;
  final bool isBanned;
  final bool hasChildren;
  final bool hasParent;
  final int? parentId;
  final bool hasLarge;

  double get aspectRatio => width / height;

  PostName get name {
    return PostName(
      artistTags: artistTags.join(' '),
      characterTags: characterTags.join(' '),
      copyrightTags: copyrightTags.join(' '),
    );
  }

  bool get isVideo {
    //TODO: handle other kind of video format
    final supportVideoFormat = ['mp4', 'webm', 'zip'];
    if (supportVideoFormat.contains(format)) {
      return true;
    } else {
      return false;
    }
  }

  bool get isAnimated {
    return isVideo || (format == 'gif');
  }

  bool get isTranslated => tags.contains('translated');

  bool get hasComment => lastCommentAt != null;

  String get downloadUrl => isVideo ? normalImageUrl : fullImageUrl;

  bool get hasBothParentAndChildren => hasChildren && hasParent;
  bool get hasParentOrChildren => hasChildren || hasParent;

  double get upvotePercent => upScore / (upScore + -downScore);

  @override
  List<Object?> get props => [id];
}

bool isPostBanned(Post post) => post.id <= 0;
bool isPostValid(Post post) => post.id > 0;
