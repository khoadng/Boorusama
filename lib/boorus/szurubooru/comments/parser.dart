// Package imports:
import 'package:booru_clients/szurubooru.dart';

// Project imports:
import 'types.dart';

SzurubooruComment parseSzurubooruComment(CommentDto e) {
  return SzurubooruComment(
    id: e.id ?? 0,
    postId: e.postId ?? 0,
    version: _versionValue(e.version),
    body: e.text ?? '',
    createdAt: e.creationTime != null ? DateTime.parse(e.creationTime!) : null,
    updatedAt: e.lastEditTime != null ? DateTime.parse(e.lastEditTime!) : null,
    creatorName: e.user?.name,
    score: e.score ?? 0,
    ownScore: e.ownScore ?? 0,
  );
}

int _versionValue(SzurubooruVersion? version) => switch (version) {
  IntVersion(value: final value) => value,
  StringVersion(value: final value) => int.tryParse(value) ?? 0,
  _ => 0,
};
