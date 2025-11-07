// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';

class DmailFolderNotifier
    extends FamilyNotifier<DmailFolderType, BooruConfigAuth> {
  @override
  DmailFolderType build(BooruConfigAuth arg) => DmailFolderType.received;

  void changeFolder(DmailFolderType folder) {
    state = folder;
  }

  void changeFolderFromString(String? folderName) {
    if (folderName == null) return;

    final folder = switch (folderName) {
      'all' => DmailFolderType.all,
      'received' => DmailFolderType.received,
      'unread' => DmailFolderType.unread,
      'sent' => DmailFolderType.sent,
      'deleted' => DmailFolderType.deleted,
      _ => null,
    };

    if (folder != null) {
      state = folder;
    }
  }
}

final dmailFolderProvider =
    NotifierProvider.family<
      DmailFolderNotifier,
      DmailFolderType,
      BooruConfigAuth
    >(DmailFolderNotifier.new);
