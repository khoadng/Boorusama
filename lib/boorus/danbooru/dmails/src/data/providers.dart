// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../client_provider.dart';
import '../../../configs/providers.dart';
import '../../../users/creator/providers.dart';
import '../types/dmail.dart';
import 'converter.dart';

final danbooruDmailsProvider = FutureProvider.autoDispose
    .family<List<Dmail>, (BooruConfigAuth, DmailFolderType?)>((
      ref,
      data,
    ) async {
      final (config, folderType) = data;
      final client = ref.watch(danbooruClientProvider(config));
      final dmails = await client.getDmails(
        limit: 1000,
        folder: folderType,
      );

      ref.invalidate(danbooruUnreadDmailsProvider);

      if (dmails.isNotEmpty) {
        final userList = dmails
            .expand((e) => {e.fromId, e.toId, e.ownerId}.nonNulls)
            .toList();

        unawaited(
          ref.read(danbooruCreatorsProvider(config).notifier).load(userList),
        );
      }

      return dmails.map((e) => dmailDtoToDmail(e)).toList();
    });

final danbooruUnreadDmailsProvider = FutureProvider.autoDispose
    .family<List<Dmail>, BooruConfigAuth>((ref, config) async {
      final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

      if (!loginDetails.hasLogin()) return [];
      final client = ref.watch(danbooruClientProvider(config));

      final dmails = await client.getDmails(
        limit: 100,
        folder: DmailFolderType.unread,
      );

      return dmails.map((e) => dmailDtoToDmail(e)).toList();
    });
