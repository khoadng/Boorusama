// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../details/providers.dart';
import '../danbooru_pool.dart';

class PoolTiles extends StatelessWidget {
  const PoolTiles({
    required this.pools,
    super.key,
  });

  final List<DanbooruPool> pools;

  @override
  Widget build(BuildContext context) {
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pools.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '${pools.length} Pool${pools.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
                        e.name.replaceAll('_', ' '),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${e.postCount} posts'),
                      trailing: const Icon(Symbols.keyboard_arrow_right),
                      onTap: () => goToPoolDetailPage(context, e),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Column(
        //   children: [
        //     ...pools.mapIndexed(
        //       (index, e) => ListTile(
        //         dense: true,
        //         onTap: () => goToPoolDetailPage(context, e),
        //         visualDensity: const ShrinkVisualDensity(),
        //         title: Text(
        //           e.name.replaceAll('_', ' '),
        //           overflow: TextOverflow.fade,
        //           maxLines: 1,
        //           softWrap: false,
        //           style: Theme.of(context).textTheme.titleSmall,
        //         ),
        //         trailing: const Icon(
        //           Symbols.keyboard_arrow_right,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
