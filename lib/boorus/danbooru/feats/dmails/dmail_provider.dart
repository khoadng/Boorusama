// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'dmail.dart';

final danbooruDmailsProvider = FutureProvider.autoDispose
    .family<List<Dmail>, (BooruConfig, DmailFolderType?)>((ref, data) async {
  final (config, folderType) = data;
  final client = ref.watch(danbooruClientProvider(config));
  final dmails = await client.getDmails(
    limit: 1000,
    folder: folderType,
  );

  ref.invalidate(danbooruUnreadDmailsProvider);

  if (dmails.isNotEmpty) {
    final userList = dmails
        .expand((e) => {e.fromId, e.toId, e.ownerId}.whereNotNull())
        .toList();

    ref.read(danbooruCreatorsProvider(config).notifier).load(userList);
  }

  return dmails.map((e) => dmailDtoToDmail(e)).toList();
});

final danbooruUnreadDmailsProvider = FutureProvider.autoDispose
    .family<List<Dmail>, BooruConfig>((ref, config) async {
  final client = ref.watch(danbooruClientProvider(config));

  final dmails = await client.getDmails(
    limit: 100,
    folder: DmailFolderType.unread,
  );

  return dmails.map((e) => dmailDtoToDmail(e)).toList();
});

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
