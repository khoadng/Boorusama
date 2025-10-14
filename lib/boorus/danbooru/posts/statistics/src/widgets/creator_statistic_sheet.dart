// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../foundation/utils/statistics.dart';
import '../../../../users/creator/providers.dart';

class CreatorStatisticSheet extends ConsumerWidget {
  const CreatorStatisticSheet({
    required this.totalPosts,
    required this.stats,
    required this.title,
    super.key,
  });

  final int totalPosts;
  final Map<String, int> stats;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final creators = ref.watch(danbooruCreatorsProvider(config));

    return StatisticsFromMapPage(
      title: title,
      total: totalPosts,
      titleFormatter: (value) => value.replaceAll('_', ' '),
      data: () {
        final data = <String, int>{};

        for (final s in stats.topN().entries) {
          final key = int.tryParse(s.key);
          if (key == null) continue;

          data[creators[key]?.name ?? s.key] = s.value;
        }

        return data;
      }(),
    );
  }
}
