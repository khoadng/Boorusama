// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';

final moebooruClientProvider = Provider<MoebooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return MoebooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});
