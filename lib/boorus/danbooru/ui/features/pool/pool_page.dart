// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/no_data_box.dart';
import 'pool_options_header.dart';
import 'pool_search_button.dart';
import 'sliver_pool_grid.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({
    super.key,
    this.useAppBarPadding = true,
  });

  final bool useAppBarPadding;

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
        appBar: AppBar(
          title: const Text('pool.pool_gallery').tr(),
          primary: widget.useAppBarPadding,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: const [
            PoolSearchButton(),
          ],
        ),
        body: const SafeArea(
          bottom: false,
          child: _PostList(),
        ),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList();

  @override
  Widget build(BuildContext context) {
    final pState = context.watch<PoolBloc>().state;
    final poState = context.watch<PoolOverviewBloc>().state;

    return InfiniteLoadListScrollView(
      isLoading: pState.status == LoadStatus.loading,
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
        Future.delayed(
          const Duration(milliseconds: 500),
          () => controller.refreshCompleted(),
        );
      },
      sliverBuilder: (controller) => [
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
                  return const SliverToBoxAdapter(child: NoDataBox());
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
                  child: ErrorBox(),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
