// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_overview_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  final ValueNotifier<bool> _searching = ValueNotifier(false);

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
        )
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
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
          SliverToBoxAdapter(
            child: _buildHeader(),
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
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: GestureDetector(
                              onTap: () => AppRouter.router.navigateTo(
                                context,
                                'pool/detail',
                                routeSettings: RouteSettings(arguments: [
                                  state.pools[index].pool,
                                ]),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildPoolImage(state.pools[index]),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      state.pools[index].pool.name
                                          .removeUnderscoreWithSpace(),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.pools.length,
                    ),
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
      title: ValueListenableBuilder<bool>(
        valueListenable: _searching,
        builder: (context, value, child) {
          if (value) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => _searching.value = false,
                      icon: const FaIcon(FontAwesomeIcons.arrowLeft)),
                  const Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(bottom: 11, top: 11, right: 15),
                      hintText: 'Search a pool',
                    ),
                  )),
                ],
              ),
            );
          } else {
            return const Text('Pool Gallery');
          }
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _searching,
          builder: (context, value, child) {
            if (value) {
              return const SizedBox.shrink();
            } else {
              return IconButton(
                onPressed: () => _searching.value = true,
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPoolImage(PoolItem pool) => Stack(
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

  Widget _buildHeader() {
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
