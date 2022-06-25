// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class PoolTiles extends StatelessWidget {
  const PoolTiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          return SliverToBoxAdapter(
            child: Material(
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  ...state.data!.mapIndexed(
                    (index, e) => ListTile(
                      dense: true,
                      onTap: () => AppRouter.router.navigateTo(
                        context,
                        'pool/detail',
                        routeSettings: RouteSettings(arguments: [e]),
                      ),
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      title: Text(
                        e.name.removeUnderscoreWithSpace(),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      trailing: const FaIcon(
                        FontAwesomeIcons.angleRight,
                        size: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }
}
