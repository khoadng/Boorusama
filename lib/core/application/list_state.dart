part of 'list_state_notifier.dart';

@freezed
abstract class ListState<T> with _$ListState<T> {
  const factory ListState({
    @required List<T> items,
    @required int page,
    @required ListItemStatus<T> status,
    @required @nullable T currentViewingItem,
    @required @nullable T lastViewedItem,
    @required int lastViewedItemIndex,
  }) = _ListState<T>;

  factory ListState.initial() => ListState<T>(
        items: [],
        page: 1,
        status: ListItemStatus.empty(),
        currentViewingItem: null,
        lastViewedItem: null,
        lastViewedItemIndex: -1,
      );
}
