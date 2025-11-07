// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/pool_category.dart';
import '../types/pool_order.dart';

class DanbooruPoolFilterState extends Equatable {
  const DanbooruPoolFilterState({
    required this.category,
    required this.order,
  });

  final DanbooruPoolCategory category;
  final DanbooruPoolOrder order;

  DanbooruPoolFilterState copyWith({
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
  }) {
    return DanbooruPoolFilterState(
      category: category ?? this.category,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [category, order];
}

class _DanbooruPoolFilterNotifier extends Notifier<DanbooruPoolFilterState> {
  @override
  DanbooruPoolFilterState build() {
    return const DanbooruPoolFilterState(
      category: DanbooruPoolCategory.series,
      order: DanbooruPoolOrder.latest,
    );
  }

  void setCategory(DanbooruPoolCategory category) {
    state = state.copyWith(category: category);
  }

  void setOrder(DanbooruPoolOrder order) {
    state = state.copyWith(order: order);
  }
}

final danbooruPoolFilterProvider =
    NotifierProvider<_DanbooruPoolFilterNotifier, DanbooruPoolFilterState>(
      _DanbooruPoolFilterNotifier.new,
    );
