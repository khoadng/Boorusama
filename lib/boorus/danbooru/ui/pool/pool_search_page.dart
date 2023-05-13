// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/no_data_box.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'sliver_pool_grid.dart';

class PoolSearchPage extends StatefulWidget {
  const PoolSearchPage({super.key});

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
            return !state.isDone
                ? state.pools.isNotEmpty
                    ? ListView.builder(
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
                              textEditingController.text =
                                  pool.name.replaceAll('_', ' ');
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
                      )
                    : const SizedBox.shrink()
                : BlocBuilder<PoolBloc, PoolState>(builder: (context, pState) {
                    return _buildList(state, pState, context);
                  });
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
    return InfiniteLoadListScrollView(
      isLoading: pState.status == LoadStatus.loading,
      enableRefresh: false,
      enableLoadMore: pState.hasMore,
      onLoadMore: () =>
          context.read<PoolBloc>().add(PoolFetched(name: psState.query)),
      onRefresh: (controller) {
        context.read<PoolBloc>().add(PoolRefreshed(name: psState.query));
        Future.delayed(
          const Duration(milliseconds: 500),
          () => controller.refreshCompleted(),
        );
      },
      sliverBuilder: (controller) => [
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
                  return const SliverToBoxAdapter(child: NoDataBox());
                }

                return SliverPoolGrid(
                  pools: state.pools,
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

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    final searchBloc = context.read<PoolSearchBloc>();

    return BooruSearchBar(
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
          return query.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    textEditingController.clear();
                    searchBloc.add(const PoolSearchCleared());
                  },
                  icon: const Icon(Icons.close),
                )
              : const SizedBox.shrink();
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

Color _poolCategoryToColor(PoolCategory category) => switch (category) {
      PoolCategory.series => TagColors.dark().copyright,
      _ => TagColors.dark().general,
    };
