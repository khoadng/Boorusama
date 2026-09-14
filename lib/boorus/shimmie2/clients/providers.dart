// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/http/client/providers.dart';
import '../extensions/providers.dart';
import '../extensions/types.dart';
import 'cache.dart';

final _graphQLCacheFactoryProvider = Provider<GraphQLCacheFactory>(
  (_) => const HiveGraphQLCacheFactory(),
);

final _graphQLCacheProvider = Provider<GraphQLCache>((ref) {
  final factory = ref.watch(_graphQLCacheFactoryProvider);
  return LazyGraphQLCache(factory.create);
});

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));
    final cache = ref.watch(_graphQLCacheProvider);

    return Shimmie2Client(
      dio: dio,
      baseUrl: config.url,
      apiKey: config.apiKey,
      username: config.login,
      cookie: config.passHash,
      graphQLCache: cache,
    );
  },
);

final useGraphQLClientProvider = FutureProvider.family<bool, BooruConfigAuth>(
  (ref, auth) async {
    final extensionsState = await ref.watch(
      shimmie2ExtensionsProvider(auth.url).future,
    );

    return switch (extensionsState) {
      final Shimmie2ExtensionsData data =>
        !data.isPartial && data.hasExtension(KnownExtension.graphql),
      _ => false,
    };
  },
);
