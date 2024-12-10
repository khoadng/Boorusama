// Package imports:

// Project imports:
import '../../../users/creator/creator.dart';
import '../../../users/user/user.dart';
import '../types/danbooru_post_version.dart';

DanbooruPostVersion convertDtoToPostVersion(dynamic e, int id) =>
    DanbooruPostVersion(
      id: id,
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
        level: stringToUserLevel(e.updater?.levelString),
      ),
    );
