// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/pool_details_order.dart';

class PoolFilterState extends Equatable {
  const PoolFilterState({
    required this.order,
  });

  final PoolDetailsOrder order;

  PoolFilterState copyWith({
    PoolDetailsOrder? order,
  }) {
    return PoolFilterState(
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    order,
  ];
}

final poolFilterProvider =
    NotifierProvider.autoDispose<PoolFilterNotifier, PoolFilterState>(
      PoolFilterNotifier.new,
    );

class PoolFilterNotifier extends AutoDisposeNotifier<PoolFilterState> {
  @override
  PoolFilterState build() {
    return const PoolFilterState(
      order: PoolDetailsOrder.order,
    );
  }

  void setOrder(PoolDetailsOrder order) {
    state = state.copyWith(order: order);
  }
}
