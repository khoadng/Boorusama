// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'sliver_pool_grid.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PoolOverviewBloc, PoolOverviewState>(
          listener: (context, state) {
            context.read<PoolBloc>().add(PoolRefreshed(
                  category: state.category,
                  order: state.order,
                ));
          },
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<PoolOverviewBloc, PoolOverviewState>(
            builder: (context, poState) {
              return BlocBuilder<PoolBloc, PoolState>(
                buildWhen: (previous, current) => !current.hasMore,
                builder: (context, pState) =>
                    _buildList(pState, context, poState),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    PoolState pState,
    BuildContext context,
    PoolOverviewState poState,
  ) {
    return InfiniteLoadList(
      extendBody: true,
      enableRefresh: false,
      enableLoadMore: pState.hasMore,
      onLoadMore: () => context.read<PoolBloc>().add(PoolFetched(
            category: poState.category,
            order: poState.order,
          )),
      onRefresh: (controller) {
        context.read<PoolBloc>().add(PoolRefreshed(
              category: poState.category,
              order: poState.order,
            ));
        Future.delayed(const Duration(milliseconds: 500),
            () => controller.refreshCompleted());
      },
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: PoolOptionsHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            sliver: BlocBuilder<PoolBloc, PoolState>(
              buildWhen: (previous, current) =>
                  current.status != LoadStatus.loading,
              builder: (context, state) {
                if (state.status == LoadStatus.initial) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (state.status == LoadStatus.success) {
                  if (state.pools.isEmpty) {
                    return const SliverToBoxAdapter(
                        child: Center(child: Text('No data')));
                  }
                  return BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      return SliverPoolGrid(
                        pools: state.pools,
                        spacing: settingsState.settings.imageGridSpacing,
                      );
                    },
                  );
                } else if (state.status == LoadStatus.loading) {
                  return const SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  );
                } else {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('Something went wrong'),
                    ),
                  );
                }
              },
            ),
          ),
          BlocBuilder<PoolBloc, PoolState>(
            builder: (context, state) {
              if (state.status == LoadStatus.loading) {
                return const SliverPadding(
                  padding: EdgeInsets.only(bottom: 20, top: 20),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('pool.pool_gallery').tr(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        _buildSearchButton(context),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => PoolBloc(
                        poolRepository: context.read<PoolRepository>(),
                        postRepository: context.read<IPostRepository>(),
                      ),
                    ),
                    BlocProvider(
                        create: (context) => PoolSearchBloc(
                            poolRepository: context.read<PoolRepository>())),
                  ],
                  child: const PoolSearchPage(),
                )));
      },
      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
    );
  }
}

class PoolOptionsHeader extends StatelessWidget {
  const PoolOptionsHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ToggleSwitch(
            minHeight: 30,
            minWidth: 100,
            cornerRadius: 10,
            totalSwitches: 2,
            borderWidth: 1,
            inactiveBgColor: Theme.of(context).chipTheme.backgroundColor,
            activeBgColor: [Theme.of(context).colorScheme.primary],
            labels: [PoolCategory.series.name, PoolCategory.collection.name],
            onToggle: (index) {
              context.read<PoolOverviewBloc>().add(PoolOverviewChanged(
                    category: index == 0
                        ? PoolCategory.series
                        : PoolCategory.collection,
                  ));
            },
          ),
          BlocBuilder<PoolOverviewBloc, PoolOverviewState>(
            buildWhen: (previous, current) => previous.order != current.order,
            builder: (context, state) {
              return TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.headline6!.color, backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Screen.of(context).size == ScreenSize.small
                      ? showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => const _OrderMenu())
                      : showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                content: _OrderMenu(),
                              ));
                },
                child: Row(
                  children: <Widget>[
                    Text(_poolOrderToString(state.order)).tr(),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrderMenu extends StatelessWidget {
  const _OrderMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<PoolOverviewBloc>(context),
      child: Material(
        child: SafeArea(
          top: false,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: PoolOrder.values
                  .map((e) => ListTile(
                        title: Text(_poolOrderToString(e)).tr(),
                        onTap: () {
                          AppRouter.router.pop(context);
                          context
                              .read<PoolOverviewBloc>()
                              .add(PoolOverviewChanged(order: e));
                        },
                      ))
                  .toList()),
        ),
      ),
    );
  }
}

String _poolOrderToString(PoolOrder order) {
  switch (order) {
    case PoolOrder.newest:
      return 'pool.order.new';
    case PoolOrder.postCount:
      return 'pool.order.post_count';
    case PoolOrder.name:
      return 'pool.order.name';
    default:
      return 'pool.order.recent';
  }
}
