// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/core/application/list_item_status.dart';

part 'list_state.dart';
part 'list_state_notifier.freezed.dart';

typedef GetItemsFutureCallback<T> = Future<List<T>> Function();
typedef StateChangedCallback<T> = void Function(ListState<T> state);

class ListStateNotifier<T> extends StateNotifier<ListState<T>> {
  ListStateNotifier() : super(ListState<T>.initial());

  void refresh({
    @required GetItemsFutureCallback<T> callback,
    @required StateChangedCallback<T> onStateChanged,
  }) async {
    state = state.copyWith(
      items: [],
      page: 1,
      status: ListItemStatus.refreshing(),
    );
    onStateChanged(state);

    try {
      final items = await callback();

      state = state.copyWith(
        items: items,
        page: 1,
        status: ListItemStatus.fetched(),
      );
      onStateChanged(state);
    } on Error {
      state = state.copyWith(
        status: ListItemStatus.error(),
      );
      onStateChanged(state);
    }
  }

  void getMoreItems({
    @required GetItemsFutureCallback<T> callback,
    @required StateChangedCallback<T> onStateChanged,
  }) async {
    final nextPage = state.page + 1;
    state = state.copyWith(
      status: ListItemStatus.loading(),
    );
    onStateChanged(state);

    try {
      final items = await callback();

      state = state.copyWith(
        items: [...state.items, ...items],
        page: nextPage,
        status: ListItemStatus.fetched(),
      );
      onStateChanged(state);
    } on Error {
      state = state.copyWith(
        status: ListItemStatus.error(),
      );
      onStateChanged(state);
    }
  }
}
