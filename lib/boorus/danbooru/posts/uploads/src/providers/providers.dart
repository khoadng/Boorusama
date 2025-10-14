// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../client_provider.dart';
import 'danbooru_upload_repository.dart';

final danbooruUploadRepoProvider =
    Provider.family<DanbooruUploadRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(danbooruClientProvider(config));

      return DanbooruUploadRepository(client: client);
    });

final danbooruIqdbResultProvider = FutureProvider.autoDispose
    .family<List<IqdbResultDto>, int>(
      (ref, mediaAssetId) {
        final client = ref.watch(danbooruClientProvider(ref.watchConfigAuth));

        return client.iqdb(mediaAssetId: mediaAssetId);
      },
    );
