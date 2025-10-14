// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../client_provider.dart';
import '../../../configs/providers.dart';
import '../types/dmail_id.dart';

class UnreadDmailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<DmailId>, BooruConfigAuth> {
  @override
  Future<List<DmailId>> build(BooruConfigAuth arg) async {
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(arg));

    if (!loginDetails.hasLogin()) return [];

    final client = ref.watch(danbooruClientProvider(arg));

    final dmails = await client.getDmails(
      limit: 100,
      folder: DmailFolderType.unread,
    );

    return dmails.map((e) => DmailId.tryParse(e.id)).nonNulls.toList();
  }

  void removeFromUnread(DmailId id) {
    state = state.whenData(
      (ids) => ids.where((e) => e != id).toList(),
    );
  }

  void addToUnread(DmailId id) {
    state = state.whenData((ids) => [...ids, id]);
  }
}

final danbooruUnreadDmailsProvider = AsyncNotifierProvider.autoDispose
    .family<UnreadDmailsNotifier, List<DmailId>, BooruConfigAuth>(
      UnreadDmailsNotifier.new,
    );
