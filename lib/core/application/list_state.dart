part of 'list_state_notifier.dart';

@freezed
abstract class ListState<T> with _$ListState<T> {
  const factory ListState({
    @required List<T> items,
    @required int page,
    @required ListItemStatus<T> status,
  }) = _ListState<T>;

  factory ListState.initial() => ListState<T>(
        items: [],
        page: 1,
        status: ListItemStatus.empty(),
      );
}
