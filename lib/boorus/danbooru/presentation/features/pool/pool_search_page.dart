// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
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

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const FaIcon(FontAwesomeIcons.arrowLeft)),
          Expanded(
              child: TextField(
            controller: textEditingController,
            autofocus: true,
            onTap: () =>
                context.read<PoolSearchBloc>().add(const PoolSearchResumed()),
            onChanged: (value) {
              context.read<PoolSearchBloc>().add(PoolSearched(value));
            },
            onSubmitted: (value) {
              context.read<PoolSearchBloc>().add(PoolSearchItemSelect(value));
              context.read<PoolBloc>().add(PoolRefreshed(name: value));
            },
            decoration: const InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
              hintText: 'Search a pool',
            ),
          )),
          BlocSelector<PoolSearchBloc, PoolSearchState, String>(
            selector: (state) => state.query,
            builder: (context, query) {
              if (query.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    textEditingController.clear();
                    context
                        .read<PoolSearchBloc>()
                        .add(const PoolSearchCleared());
                  },
                  icon: const FaIcon(FontAwesomeIcons.xmark),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          )
        ],
      ),
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
