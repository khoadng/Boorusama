// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/utils.dart';
import 'sliver_pool_grid.dart';

class PoolSearchPage extends StatefulWidget {
  const PoolSearchPage({Key? key}) : super(key: key);

  @override
  State<PoolSearchPage> createState() => _PoolSearchPageState();
}

class _PoolSearchPageState extends State<PoolSearchPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(context),
      ),
      body: SafeArea(
        child: BlocBuilder<PoolSearchBloc, PoolSearchState>(
          builder: (context, state) {
            if (!state.isDone) {
              if (state.pools.isNotEmpty) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final pool = state.pools[index];
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        pool.name.removeUnderscoreWithSpace(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _poolCategoryToColor(pool.category),
                        ),
                      ),
                      trailing: Text(
                        NumberFormat.compact().format(pool.postCount),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        textEditingController.text = pool.name;
                        context
                            .read<PoolSearchBloc>()
                            .add(PoolSearchItemSelect(pool.name));

                        context
                            .read<PoolBloc>()
                            .add(PoolRefreshed(name: pool.name));
                      },
                    );
                  },
                  itemCount: state.pools.length,
                );
              } else {
                return const SizedBox.shrink();
              }
            } else {
              return BlocBuilder<PoolBloc, PoolState>(
                builder: (context, pState) {
                  return _buildList(state, pState, context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildList(
    PoolSearchState psState,
    PoolState pState,
    BuildContext context,
  ) {
    return InfiniteLoadList(
      enableRefresh: false,
      enableLoadMore: pState.hasMore,
      onLoadMore: () =>
          context.read<PoolBloc>().add(PoolFetched(name: psState.query)),
      onRefresh: (controller) {
        context.read<PoolBloc>().add(PoolRefreshed(name: psState.query));
        Future.delayed(const Duration(milliseconds: 500),
            () => controller.refreshCompleted());
      },
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: <Widget>[
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

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    final searchBloc = context.read<PoolSearchBloc>();
    return SearchBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
        ),
      ),
      queryEditingController: textEditingController,
      autofocus: true,
      trailing: BlocSelector<PoolSearchBloc, PoolSearchState, String>(
        selector: (state) => state.query,
        builder: (context, query) {
          if (query.isNotEmpty) {
            return IconButton(
              onPressed: () {
                textEditingController.clear();
                searchBloc.add(const PoolSearchCleared());
              },
              icon: const Icon(Icons.close),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      onChanged: (value) => searchBloc.add(PoolSearched(value)),
      onSubmitted: (value) {
        searchBloc.add(PoolSearchItemSelect(value));
        context.read<PoolBloc>().add(PoolRefreshed(name: value));
      },
      hintText: 'pool.search.hint'.tr(),
      onTap: () => searchBloc.add(const PoolSearchResumed()),
    );
  }
}

Color _poolCategoryToColor(PoolCategory category) {
  switch (category) {
    case PoolCategory.series:
      return TagColors.dark().copyright;
    default:
      return TagColors.dark().general;
  }
}
