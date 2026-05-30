// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/types.dart';
import '../../../../core/text_markup/types.dart';
import '../../client_provider.dart';
import 'repository.dart';

final danbooruTextMarkupRepositoryProvider =
    Provider.family<TextMarkupRepository, BooruConfigAuth>((ref, config) {
      return DanbooruTextMarkupRepository(
        client: ref.watch(danbooruClientProvider(config)),
      );
    });
