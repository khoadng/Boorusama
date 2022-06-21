// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool_bloc.dart';

class PoolImage extends StatelessWidget {
  const PoolImage({
    Key? key,
    required this.pool,
  }) : super(key: key);

  final PoolItem pool;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (pool.coverUrl != null)
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
            imageUrl: pool.coverUrl!,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Center(
              child: Text('NSFW'),
            ),
          ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            color: Theme.of(context).cardColor,
            height: 25,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  pool.pool.postCount.toString(),
                ),
                const FaIcon(FontAwesomeIcons.image)
              ],
            ),
          ),
        )
      ],
    );
  }
}
