// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final hydrusClientProvider = Provider.family<HydrusClient, BooruConfigAuth>((
  ref,
  config,
) {
  final dio = ref.watch(dioProvider(config));

  return HydrusClient(
    dio: dio,
    baseUrl: config.url,
    apiKey: config.apiKey ?? '',
  );
});
