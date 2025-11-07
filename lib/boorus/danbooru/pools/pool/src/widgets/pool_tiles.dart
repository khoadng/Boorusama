// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../details/routes.dart';
import '../types/danbooru_pool.dart';

class PoolTiles extends ConsumerWidget {
  const PoolTiles({
    required this.pools,
    super.key,
  });

  final List<DanbooruPool> pools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pools.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pools.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    context.t.pool.counter(n: pools.length),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.outline,
                    ),
                  ),
                ),
              ...pools.map(
                (e) => Column(
                  children: [
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      dense: true,
                      minVerticalPadding: 0,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        e.name?.replaceAll('_', ' ') ?? '???',
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: switch (e.postCount) {
                        final count? => Text(
                          context.t.posts.counter(n: count),
                        ),
                        _ => null,
                      },
                      trailing: const Icon(Symbols.keyboard_arrow_right),
                      onTap: () => goToPoolDetailPage(ref, e),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
