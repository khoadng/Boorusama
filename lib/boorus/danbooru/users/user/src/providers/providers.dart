// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/cache/persistent/providers.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../foundation/riverpod/riverpod.dart';
import '../../../../client_provider.dart';
import '../../../../configs/providers.dart';
import '../data/providers.dart';
import '../types/user.dart';
import 'users_notifier.dart';

class DanbooruUserDetails extends Equatable {
  const DanbooruUserDetails({
    required this.user,
    required this.previousNames,
  });

  final DanbooruUser user;
  final List<String> previousNames;

  @override
  List<Object?> get props => [user, previousNames];
}

const _kCurrentUserIdKey = '_current_uid';

final danbooruCurrentUserProvider =
    FutureProvider.family<UserSelf?, BooruConfigAuth>((ref, config) async {
      final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
      if (!loginDetails.hasLogin()) return null;

      // First, we try to get the user id from the cache
      final miscData = await ref.watch(persistentCacheBoxProvider.future);
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

      return requests.map((e) => e.originalName).nonNulls.toList();
    });

final danbooruUserDetailsProvider = FutureProvider.autoDispose
    .family<DanbooruUserDetails, (BooruConfigAuth, int)>((
      ref,
      params,
    ) async {
      final (config, userId) = params;

      final results = await Future.wait([
        ref.watch(danbooruUserProvider(userId).future),
        ref.watch(danbooruUserPreviousNamesProvider((config, userId)).future),
      ]);

      final user = results[0] as DanbooruUser;
      final previousNames = results[1] as List<String>;

      return DanbooruUserDetails(
        user: user,
        previousNames: previousNames,
      );
    });
