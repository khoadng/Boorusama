// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/e621/e621_client.dart';

final e621ClientProvider = Provider<E621Client>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return E621Client(
    baseUrl: booruConfig.url,
    dio: dio,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );
});
