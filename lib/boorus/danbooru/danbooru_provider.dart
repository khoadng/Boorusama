// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config.dart';
import '../../core/http/providers.dart';
import 'danbooru.dart';

final danbooruClientProvider =
    Provider.family<DanbooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return DanbooruClient(
    dio: dio,
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
  );
});

final danbooruProvider = Provider<Danbooru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<Danbooru>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.danbooru}');
    }

    return booru;
  },
);
