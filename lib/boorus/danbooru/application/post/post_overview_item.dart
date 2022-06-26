// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/i_downloadable.dart';

@immutable
class PostOverviewItem implements IDownloadable {
  const PostOverviewItem({
    required this.id,
    required this.isAnimated,
    required this.previewImageUrl,
    required this.fullImageUrl,
    required this.normalImageUrl,
    required this.downloadUrl,
    required this.fileName,
    required this.isTranslated,
    required this.hasComments,
    required this.hasChidren,
    required this.hasParent,
    required this.artistTags,
    required this.characterTags,
    required this.copyrightTags,
  });
  final int id;
  final bool isAnimated;
  final String previewImageUrl;
  final String normalImageUrl;
  final String fullImageUrl;
  @override
  final String downloadUrl;
  @override
  final String fileName;
  final bool isTranslated;
  final bool hasComments;
  final bool hasChidren;
  final bool hasParent;
  final List<String> artistTags;
  final List<String> characterTags;
  final List<String> copyrightTags;
}

PostOverviewItem postToPostOverviewItem(Post post) => PostOverviewItem(
      id: post.id,
      isAnimated: post.isAnimated,
      previewImageUrl: post.previewImageUrl,
      normalImageUrl: post.normalImageUrl,
      fullImageUrl: post.fullImageUrl,
      downloadUrl: post.downloadUrl,
      fileName: post.fileName,
      isTranslated: post.isTranslated,
      hasComments: post.hasComment,
      hasChidren: post.hasChildren,
      hasParent: post.hasParent,
      artistTags: post.artistTags,
      copyrightTags: post.copyrightTags,
      characterTags: post.characterTags,
    );
