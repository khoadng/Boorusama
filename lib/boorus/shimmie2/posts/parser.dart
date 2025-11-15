// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

Shimmie2Post postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  return Shimmie2Post(
    id: e.id ?? 0,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.fileUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    tags: e.tags?.toSet() ?? {},
    rating: Rating.parse(e.rating),
    hasComment: switch (e.comments) {
      final comments? when comments.isNotEmpty => true,
      _ => false,
    },
    comments: e.comments,
    isTranslated: switch (e.notes) {
      final notes? when notes > 0 => true,
      _ => false,
    },
    hasParentOrChildren: switch ((e.parentId, e.hasChildren)) {
      (final int _, _) => true,
      (_, final hasChildren?) when hasChildren => true,
      _ => false,
    },
    source: PostSource.from(e.source),
    score: e.score ?? e.numericScore ?? 0,
    duration: 0,
    fileSize: e.filesize ?? 0,
    format: switch ((e.ext, e.fileName)) {
      (final ext?, _) => ext,
      (_, final fileName?) => extension(fileName),
      _ => '',
    },
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    createdAt: e.date,
    uploaderId: null,
    uploaderName: switch ((e.author, e.ownerName)) {
      (final author?, _) => author,
      (_, final ownerName?) => ownerName,
      _ => null,
    },
    metadata: metadata,
    parentId: e.parentId,
    locked: e.locked,
    ext: e.ext,
    mime: e.mime,
    niceName: e.niceName,
    tooltip: e.tooltip,
    favorites: e.favorites,
    numericScore: e.numericScore,
    notes: e.notes,
    hasChildren: e.hasChildren,
    title: e.title,
    approved: e.approved,
    approvedById: e.approvedById,
    private: e.private,
    trash: e.trash,
    ownerJoinDate: e.ownerJoinDate,
    votes: e.votes,
    myVote: e.myVote,
  );
}
