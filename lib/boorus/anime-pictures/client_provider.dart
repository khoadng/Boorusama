// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final animePicturesClientProvider =
    Provider.family<AnimePicturesClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(dioProvider(config));

        return AnimePicturesClient(
          dio: dio,
          baseUrl: config.url,
          cookie: config.passHash,
        );
      },
    );
