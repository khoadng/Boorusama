// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/widgets/faster_ink_splash.dart';
import 'package:boorusama/core/utils.dart';
import 'pool_image.dart';

class PoolGridItem extends ConsumerWidget {
  const PoolGridItem({
    super.key,
    required this.pool,
  });

  final Pool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    PoolImage(pool: pool),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashFactory: FasterInkSplash.splashFactory,
                          splashColor: Colors.black38,
                          onTap: () => goToPoolDetailPage(context, pool),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  pool.name.removeUnderscoreWithSpace(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pool.postCount.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const FaIcon(
                    FontAwesomeIcons.images,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
