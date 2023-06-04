// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class PoolTiles extends StatelessWidget {
  const PoolTiles({
    super.key,
    required this.pools,
  });

  final List<Pool> pools;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          ...pools.mapIndexed(
            (index, e) => ListTile(
              dense: true,
              onTap: () => goToPoolDetailPage(context, e),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              title: Text(
                e.name.removeUnderscoreWithSpace(),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.angleRight,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
