// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../router.dart';
import '../../../tags/tag/providers.dart';
import '../../../widgets/widgets.dart';

class SliverCharacterPostList extends ConsumerWidget {
  const SliverCharacterPostList({
    required this.tags,
    super.key,
  });

  final Set<String> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tags.isEmpty) return const SliverSizedBox.shrink();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Text(
                    'Characters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SliverSizedBox(height: 8),
          SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 4.5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: tags
                .map(
                  (tag) => BooruChip(
                    borderRadius: BorderRadius.circular(4),
                    color: ref.watch(tagColorProvider('character')),
                    onPressed: () => goToCharacterPage(context, tag),
                    label: Text(
                      tag.replaceAll('_', ' '),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
