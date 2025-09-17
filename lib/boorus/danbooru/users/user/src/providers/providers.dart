// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/cache/providers.dart';
import '../../../../../../core/configs/config.dart';
import '../../../../../../foundation/riverpod/riverpod.dart';
import '../../../../client_provider.dart';
import '../../../../configs/providers.dart';
import '../data/providers.dart';
import '../types/user.dart';

const _kCurrentUserIdKey = '_current_uid';

final danbooruCurrentUserProvider =
    FutureProvider.family<UserSelf?, BooruConfigAuth>((ref, config) async {
      final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
      if (!loginDetails.hasLogin()) return null;

      // First, we try to get the user id from the cache
      final miscData = ref.watch(miscDataBoxProvider);
      final key =
          '${_kCurrentUserIdKey}_${Uri.encodeComponent(config.url)}_${config.login}';
      final cached = miscData.get(key);
      var id = cached != null ? int.tryParse(cached) : null;

      // If the cached id is null, we need to fetch it from the api
      if (id == null) {
        final user = await ref.watch(
          danbooruUserProfileProvider(config).future,
        );

        id = user?.id;

        // If the id is not null, we cache it
        if (id != null) {
          await miscData.put(key, id.toString());
        }
      }

      // If the id is still null, we can't do anything else here
      if (id == null) return null;

      return ref.watch(danbooruUserRepoProvider(config)).getUserSelfById(id);
    });

final danbooruUserPreviousNamesProvider = FutureProvider.autoDispose
    .family<List<String>, (BooruConfigAuth, int)>((ref, params) async {
      ref.cacheFor(const Duration(minutes: 10));

      final (config, userId) = params;
      final client = ref.watch(danbooruClientProvider(config));
      final requests = await client.getUserNameChangeRequests(userId: userId);

      return requests.map((e) => e.desiredName).nonNulls.toList();
    });
