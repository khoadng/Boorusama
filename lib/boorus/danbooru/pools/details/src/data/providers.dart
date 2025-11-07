// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../client_provider.dart';
import '../types/pool_description.dart';
import 'repo.dart';

final poolDescriptionRepoProvider =
    Provider.family<PoolDescriptionRepository, BooruConfigAuth>((ref, config) {
      return PoolDescriptionRepoBuilder(
        fetchDescription: (poolId) async {
          final html = await ref
              .watch(danbooruClientProvider(config))
              .getPoolDescriptionHtml(poolId);

          final document = parse(html);

          return document.getElementById('description')?.outerHtml ?? '';
        },
      );
    });
