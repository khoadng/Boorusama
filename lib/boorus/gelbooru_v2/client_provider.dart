// Package imports:
import 'package:booru_clients/core.dart';
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';
import 'gelbooru_v2.dart';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfigAuth>((ref, config) {
      final dio = ref.watch(defaultDioProvider(config));
      final gelbooruV2 = ref.watch(gelbooruV2Provider);

      return GelbooruV2Client(
        baseUrl: config.url,
        userId: config.login,
        apiKey: config.apiKey,
        dio: dio,
        config: gelbooruV2.buildClientConfig(
          baseConfig: GelbooruV2Client.defaultEndpoints(
            globalUserParams: gelbooruV2.getGlobalUserParams(),
          ),
          siteUrl: config.url,
          parserResolver: ParserRegistry.resolve,
        ),
      );
    });
