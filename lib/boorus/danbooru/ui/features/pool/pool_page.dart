// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'pool_options_header.dart';
import 'sliver_pool_grid.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({
    super.key,
  });

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
        Future.delayed(
          const Duration(milliseconds: 500),
          () => controller.refreshCompleted(),
        );
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
          BlocBuilder<PoolBloc, PoolState>(
            builder: (context, state) {
              return state.status == LoadStatus.loading
                  ? const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink());
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
                  postRepository: context.read<PostRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => PoolSearchBloc(
                  poolRepository: context.read<PoolRepository>(),
                ),
              ),
            ],
            child: const PoolSearchPage(),
          ),
        ));
      },
      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
    );
  }
}
