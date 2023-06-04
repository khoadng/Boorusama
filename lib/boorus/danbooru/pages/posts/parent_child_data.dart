// Project imports:
import 'package:boorusama/boorus/danbooru/feat/posts/models.dart';

class ParentChildData {
  const ParentChildData({
    required this.description,
    required this.tagQueryForDataFetching,
    required this.parentId,
  });

  final String description;
  final String tagQueryForDataFetching;
  final int parentId;
}

ParentChildData getParentChildData(DanbooruPost post) => post.hasParent
    ? ParentChildData(
        description: 'post.detail.has_parent_notice',
        tagQueryForDataFetching: 'parent:${post.parentId}',
        parentId: post.parentId!,
      )
    : ParentChildData(
        description: 'post.detail.has_children_notice',
        tagQueryForDataFetching: 'parent:${post.id}',
        parentId: post.id,
      );
