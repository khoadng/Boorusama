// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/tags/configs/providers.dart';
import '../../../../client_provider.dart';
import '../../../../configs/providers.dart';
import '../types/user.dart';
import 'converter.dart';
import 'user_repository.dart';

final danbooruUserRepoProvider =
    Provider.family<DanbooruUserRepository, BooruConfigAuth>((ref, config) {
      return DanbooruUserRepository(
        ref.watch(danbooruClientProvider(config)),
        ref.watch(tagInfoProvider).defaultBlacklistedTags,
      );
    });

final danbooruUserProfileProvider =
    FutureProvider.family<DanbooruUser?, BooruConfigAuth>(
      (ref, config) async {
        final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
        if (!loginDetails.hasLogin()) return null;

        final client = ref.watch(danbooruClientProvider(config));
        final user = await client.getProfile();

        if (user == null) return null;

        return userDtoToUser(user);
      },
    );
