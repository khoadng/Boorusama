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
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class PoolTiles extends StatefulWidget {
  const PoolTiles({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<PoolTiles> createState() => _PoolTilesState();
}

class _PoolTilesState extends State<PoolTiles>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) =>
          PoolFromPostIdBloc(poolRepository: context.read<PoolRepository>())
            ..add(PoolFromPostIdRequested(postId: widget.post.id)),
      child: Builder(builder: (context) {
        return BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              return Material(
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
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
