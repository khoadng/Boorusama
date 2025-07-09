// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final e621ClientProvider = Provider.family<E621Client, BooruConfigAuth>((
  ref,
  config,
) {
  final dio = ref.watch(dioProvider(config));

  return E621Client(
    baseUrl: config.url,
    dio: dio,
    login: config.login,
    apiKey: config.apiKey,
  );
});
