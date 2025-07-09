// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../client_provider.dart';
import '../types/artist_commentary_repository.dart';
import 'artist_commentary_repository_api.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider.family<DanbooruArtistCommentaryRepository, BooruConfigAuth>(
      (ref, config) {
        return DanbooruArtistCommentaryRepositoryApi(
          ref.watch(danbooruClientProvider(config)),
        );
      },
    );
