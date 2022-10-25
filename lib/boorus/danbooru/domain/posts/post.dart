// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/core/domain/posts/media_info_mixin.dart';
import 'package:boorusama/core/domain/posts/post.dart' as base;
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/domain/posts/translatable_mixin.dart';

const pixivLinkUrl = 'https://www.pixiv.net/en/artworks/';
const censoredTags = ['loli', 'shota'];

class Post extends Equatable
    with MediaInfoMixin, TranslatedMixin
    implements base.Post {
  const Post({
    required this.id,
    required this.previewImageUrl,
    required this.normalImageUrl,
    required this.fullImageUrl,
    required this.copyrightTags,
    required this.characterTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.tags,
    required this.width,
    required this.height,
    required this.format,
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
    required this.hasParent,
    this.parentId,
    required this.hasLarge,
    required this.comments,
    required this.totalComments,
    this.artistCommentary,
  }) : _source = source;

  factory Post.empty() => Post(
        id: 0,
        previewImageUrl: '',
        normalImageUrl: '',
        fullImageUrl: '',
        copyrightTags: const [],
        characterTags: const [],
        artistTags: const [],
        generalTags: const [],
        metaTags: const [],
        tags: const [],
        width: 1,
        height: 1,
        format: 'png',
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
        hasParent: false,
        hasLarge: false,
        comments: const [],
        totalComments: 0,
      );

  @override
  final int id;
  @override
  final String previewImageUrl;
  @override
  final String normalImageUrl;
  @override
  final String fullImageUrl;
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
  final int fileSize;
  final int? pixivId;
  final bool isBanned;
  final bool hasChildren;
  final bool hasParent;
  final int? parentId;
  final bool hasLarge;
  final List<Comment> comments;
  final int totalComments;
  final ArtistCommentary? artistCommentary;

  Post copyWith({
    int? id,
    List<String>? copyrightTags,
    List<String>? characterTags,
    List<String>? artistTags,
    List<String>? generalTags,
    List<String>? metaTags,
    List<String>? tags,
    String? format,
    DateTime? lastCommentAt,
    String? normalImageUrl,
    String? fullImageUrl,
    int? upScore,
    int? downScore,
    int? score,
    int? favCount,
    bool? hasParent,
    bool? hasChildren,
    int? pixivId,
    String? source,
  }) =>
      Post(
        id: id ?? this.id,
        previewImageUrl: previewImageUrl,
        normalImageUrl: normalImageUrl ?? this.normalImageUrl,
        fullImageUrl: fullImageUrl ?? this.fullImageUrl,
        copyrightTags: copyrightTags ?? this.copyrightTags,
        characterTags: characterTags ?? this.characterTags,
        artistTags: artistTags ?? this.artistTags,
        generalTags: generalTags ?? this.generalTags,
        metaTags: metaTags ?? this.metaTags,
        tags: tags ?? this.tags,
        width: width,
        height: height,
        format: format ?? this.format,
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
        hasParent: hasParent ?? this.hasParent,
        hasLarge: hasLarge,
        comments: comments,
        totalComments: totalComments,
        artistCommentary: artistCommentary,
      );

  bool get hasComment => lastCommentAt != null;

  @override
  String get downloadUrl => isVideo ? normalImageUrl : fullImageUrl;

  bool get hasBothParentAndChildren => hasChildren && hasParent;
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
        previewImageUrl,
        normalImageUrl,
        fullImageUrl,
      ].every((e) => e != '');

  @override
  List<Object?> get props => [id];
}

bool isPostValid(Post post) => post.id != 0 && post.viewable;
