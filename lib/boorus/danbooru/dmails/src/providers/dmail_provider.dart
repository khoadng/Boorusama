// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../client_provider.dart';
import '../../../users/creator/providers.dart';
import '../types/dmail.dart';
import '../types/dmail_id.dart';
import 'folder_provider.dart';
import 'unread_provider.dart';

class DmailsNotifier extends FamilyAsyncNotifier<List<Dmail>, BooruConfigAuth> {
  @override
  Future<List<Dmail>> build(BooruConfigAuth arg) async {
    final folder = ref.watch(dmailFolderProvider(arg));
    final client = ref.watch(danbooruClientProvider(arg));

    final dmails = await client.getDmails(
      limit: 1000,
      folder: folder,
    );

    if (dmails.isNotEmpty) {
      final userList = dmails
          .expand((e) => {e.fromId, e.toId, e.ownerId}.nonNulls)
          .toList();

      unawaited(
        ref.read(danbooruCreatorsProvider(arg).notifier).load(userList),
      );
    }

    return dmails.map((e) => dmailDtoToDmail(e)).toList();
  }

  Future<void> markAsRead(DmailId id) async {
    final current = await future;

    // Optimistic update
    state = AsyncValue.data(
      current.map((e) => e.id == id ? e.markAsRead() : e).toList(),
    );

    try {
      final client = ref.read(danbooruClientProvider(arg));
      await client.markDmailAsRead(id: id.value);
      ref.read(danbooruUnreadDmailsProvider(arg).notifier).removeFromUnread(id);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> markAsUnread(DmailId id) async {
    final current = await future;

    // Optimistic update
    state = AsyncValue.data(
      current.map((e) => e.id == id ? e.markAsUnread() : e).toList(),
    );

    try {
      final client = ref.read(danbooruClientProvider(arg));
      await client.markDmailAsUnread(id: id.value);
      ref.read(danbooruUnreadDmailsProvider(arg).notifier).addToUnread(id);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final danbooruDmailsProvider =
    AsyncNotifierProvider.family<DmailsNotifier, List<Dmail>, BooruConfigAuth>(
      DmailsNotifier.new,
    );

final danbooruDmailByIdProvider = FutureProvider.autoDispose
    .family<Dmail?, (BooruConfigAuth, DmailId)>((ref, params) async {
      final (config, dmailId) = params;
      final dmails = await ref.watch(danbooruDmailsProvider(config).future);

      return dmails.firstWhereOrNull((e) => e.id == dmailId);
    });

Dmail dmailDtoToDmail(DmailDto e) {
  return Dmail(
    id: DmailId.tryParse(e.id) ?? const DmailId.invalid(),
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
