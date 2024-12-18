// Package imports:

// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/dmail.dart';

Dmail dmailDtoToDmail(DmailDto e) {
  return Dmail(
    id: e.id ?? 0,
    ownerId: e.ownerId ?? 0,
    fromId: e.fromId ?? 0,
    toId: e.toId ?? 0,
    title: e.title ?? '',
    body: e.body ?? '',
    isRead: e.isRead ?? false,
    isDeleted: e.isDeleted ?? false,
    createdAt: e.createdAt ?? DateTime(1),
    updatedAt: e.updatedAt ?? DateTime(1),
  );
}
