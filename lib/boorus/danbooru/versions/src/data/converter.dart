// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../users/creator/types.dart';
import '../../../users/user/types.dart';
import '../types/danbooru_post_version.dart';

DanbooruPostVersion convertDtoToPostVersion(PostVersionDto e) =>
    DanbooruPostVersion(
      id: e.id ?? 0,
      postId: e.postId ?? 0,
      tags: e.tags ?? '',
      addedTags: e.addedTags ?? [],
      removedTags: e.removedTags ?? [],
      updaterId: e.updaterId ?? 0,
      updatedAt: e.updatedAt != null
          ? DateTime.tryParse(e.updatedAt!) ?? DateTime.now()
          : DateTime.now(),
      rating: e.rating ?? '',
      ratingChanged: e.ratingChanged ?? false,
      parentId: e.parentId,
      parentChanged: e.parentChanged ?? false,
      source: e.source ?? '',
      sourceChanged: e.sourceChanged ?? false,
      version: e.version ?? 0,
      obsoleteAddedTags: e.obsoleteAddedTags ?? '',
      obsoleteRemovedTags: e.obsoleteRemovedTags ?? '',
      unchangedTags: e.unchangedTags ?? '',
      updater: Creator(
        id: e.updater?.id ?? 0,
        name: e.updater?.name ?? '',
        level: UserLevel.parse(e.updater?.levelString),
      ),
      thumbnailUrl: e.previewFileUrl,
    );
