// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/http/client/providers.dart';
import '../../../foundation/lazy_managed.dart';
import '../extensions/providers.dart';
import '../extensions/types.dart';
import 'cache.dart';

final shimmie2GraphQLCacheFactoryProvider = Provider<GraphQLCacheFactory>(
  (_) => const HiveGraphQLCacheFactory(),
);

final shimmie2GraphQLCacheProvider = Provider<GraphQLCache>((ref) {
  final factory = ref.watch(shimmie2GraphQLCacheFactoryProvider);
  final managed = LazyManaged<GraphQLCache>(
    create: factory.create,
    dispose: factory.dispose,
  );
  ref.onDispose(managed.close);
  return LazyGraphQLCache(managed.get);
});

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));
    final cache = ref.watch(shimmie2GraphQLCacheProvider);

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
