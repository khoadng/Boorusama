// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools/pool_overview_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/core/core.dart';

class PoolOptionsHeader extends StatelessWidget {
  const PoolOptionsHeader({
    super.key,
  });

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
            labels: [
              _poolCategoryToString(PoolCategory.series).tr(),
              _poolCategoryToString(PoolCategory.collection).tr(),
            ],
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
                  foregroundColor:
                      Theme.of(context).textTheme.titleLarge!.color,
                  backgroundColor: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                onPressed: () {
                  final bloc = context.read<PoolOverviewBloc>();
                  Screen.of(context).size == ScreenSize.small
                      ? showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => _OrderMenu(bloc),
                        )
                      : showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            content: _OrderMenu(bloc),
                          ),
                        );
                },
                child: Row(
                  children: <Widget>[
                    Text(_poolOrderToString(state.order)).tr(),
                    const Icon(Icons.arrow_drop_down),
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
  const _OrderMenu(this.bloc);

  final PoolOverviewBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Material(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: PoolOrder.values
                .map((e) => ListTile(
                      title: Text(_poolOrderToString(e)).tr(),
                      onTap: () {
                        Navigator.of(context).pop();
                        context
                            .read<PoolOverviewBloc>()
                            .add(PoolOverviewChanged(order: e));
                      },
                    ))
                .toList(),
          ),
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
    case PoolOrder.latest:
      return 'pool.order.recent';
  }
}

String _poolCategoryToString(PoolCategory category) =>
    'pool.category.${category.name}';
