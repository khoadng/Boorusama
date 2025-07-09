// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../data/providers.dart';
import '../types/danbooru_post_version.dart';

final danbooruPostVersionsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPostVersion>, int>((ref, id) async {
      final config = ref.watchConfigAuth;
      final repo = ref.watch(danbooruPostVersionsRepoProvider(config));

      return repo.getPostVersions(id: id);
    });
