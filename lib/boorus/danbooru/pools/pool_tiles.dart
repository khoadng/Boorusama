// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';

class PoolTiles extends StatelessWidget {
  const PoolTiles({
    super.key,
    required this.pools,
  });

  final List<DanbooruPool> pools;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          ...pools.mapIndexed(
            (index, e) => ListTile(
              dense: true,
              onTap: () => goToPoolDetailPage(context, e),
              visualDensity: const ShrinkVisualDensity(),
              title: Text(
                e.name.replaceUnderscoreWithSpace(),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: context.textTheme.titleSmall,
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
