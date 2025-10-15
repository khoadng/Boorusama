// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum DetailsPart {
  pool,
  info,
  toolbar,
  artistInfo,
  source,
  tags,
  stats,
  fileDetails,
  comments,
  artistPosts,
  relatedPosts,
  characterList,
  uploaderPosts,
}

final _knownPartsMap = {for (final part in DetailsPart.values) part.name: part};

DetailsPart? parseDetailsPart(String part) {
  if (_knownPartsMap.containsKey(part)) {
    return _knownPartsMap[part];
  }

  return null;
}

String translateRawDetailsPartName(BuildContext context, String name) {
  final part = parseDetailsPart(name);

  if (part == null) return name;

  return translateDetailsPart(context, part);
}

String translateDetailsPart(BuildContext context, DetailsPart part) {
  return switch (part) {
    DetailsPart.fileDetails => context.t.post.detail.widgets.file_details,
    DetailsPart.info => context.t.post.detail.widgets.info_panel,
    DetailsPart.tags => context.t.post.detail.widgets.tags,
    DetailsPart.toolbar => context.t.post.detail.widgets.toolbar,
    DetailsPart.pool => context.t.post.detail.widgets.pool,
    DetailsPart.artistInfo => context.t.post.detail.widgets.artist_info,
    DetailsPart.source => context.t.post.detail.widgets.source,
    DetailsPart.stats => context.t.post.detail.widgets.stats,
    DetailsPart.comments => context.t.post.detail.widgets.comments,
    DetailsPart.artistPosts => context.t.post.detail.widgets.artist_posts,
    DetailsPart.relatedPosts => context.t.post.detail.widgets.related_posts,
    DetailsPart.characterList => context.t.post.detail.widgets.character_list,
    DetailsPart.uploaderPosts => context.t.post.detail.widgets.uploader_posts,
  };
}
