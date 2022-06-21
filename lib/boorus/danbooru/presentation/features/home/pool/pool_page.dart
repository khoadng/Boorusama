// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_overview_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  return SliverPoolGrid(pools: state.pools);
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
      title: const Text('Pool Gallery'),
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
                  backgroundColor: Theme.of(context).cardColor,
                  primary: Theme.of(context).textTheme.headline6!.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => showMaterialModalBottomSheet(
                    context: context,
                    builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<PoolOverviewBloc>(context),
                          child: Material(
                            child: SafeArea(
                              top: false,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: PoolOrder.values
                                      .map((e) => ListTile(
                                            title: Text(e.name.sentenceCase),
                                            onTap: () {
                                              AppRouter.router.pop(context);
                                              context
                                                  .read<PoolOverviewBloc>()
                                                  .add(PoolOverviewChanged(
                                                      order: e));
                                            },
                                          ))
                                      .toList()),
                            ),
                          ),
                        )),
                child: Row(
                  children: <Widget>[
                    Text(state.order.name.sentenceCase),
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
