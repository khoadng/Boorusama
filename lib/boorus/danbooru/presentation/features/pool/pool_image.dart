// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';

// Project imports:

class PoolImage extends StatelessWidget {
  const PoolImage({
    Key? key,
    required this.pool,
  }) : super(key: key);

  final PoolItem pool;

  @override
  Widget build(BuildContext context) {
    return (pool.coverUrl != null)
        ? CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageUrl: pool.coverUrl!,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text('Mature/Banned content'),
            ),
          );
  }
}
