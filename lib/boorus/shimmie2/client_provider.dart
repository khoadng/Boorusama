// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';
import 'extensions/known_extensions.dart';
import 'extensions/providers.dart';
import 'extensions/state.dart';

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));

    return Shimmie2Client(
      dio: dio,
      baseUrl: config.url,
      apiKey: config.apiKey,
      username: config.login,
    );
  },
);

final useGraphQLClientProvider = FutureProvider.family<bool, BooruConfigAuth>(
  (ref, auth) async {
    final extensionsState = await ref.watch(
      shimmie2ExtensionsProvider(auth.url).future,
    );

    return switch (extensionsState) {
      final Shimmie2ExtensionsData data => data.hasExtension(
        KnownExtension.graphql,
      ),
      _ => false,
    };
  },
);
