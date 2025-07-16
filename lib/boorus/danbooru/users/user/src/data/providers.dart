// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/tags/configs/providers.dart';
import '../../../../client_provider.dart';
import '../types/user.dart';
import '../types/user_repository.dart';
import 'converter.dart';
import 'user_repository_api.dart';

final danbooruUserRepoProvider =
    Provider.family<UserRepository, BooruConfigAuth>((ref, config) {
      return UserRepositoryApi(
        ref.watch(danbooruClientProvider(config)),
        ref.watch(tagInfoProvider).defaultBlacklistedTags,
      );
    });

final danbooruUserProfileProvider =
    FutureProvider.family<DanbooruUser?, BooruConfigAuth>(
      (ref, config) async {
        if (!config.hasLoginDetails()) return null;

        final client = ref.watch(danbooruClientProvider(config));
        final user = await client.getProfile();

        if (user == null) return null;

        return userDtoToUser(user);
      },
    );
