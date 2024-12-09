// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/utils/flutter_utils.dart';
import '../../../details/providers.dart';
import '../danbooru_pool.dart';

class PoolTiles extends StatelessWidget {
  const PoolTiles({
    super.key,
    required this.pools,
  });

  final List<DanbooruPool> pools;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          ...pools.mapIndexed(
            (index, e) => ListTile(
              dense: true,
              onTap: () => goToPoolDetailPage(context, e),
              visualDensity: const ShrinkVisualDensity(),
              title: Text(
                e.name.replaceAll('_', ' '),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: const Icon(
                Symbols.keyboard_arrow_right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
