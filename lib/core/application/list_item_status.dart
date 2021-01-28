// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_item_status.freezed.dart';

@freezed
abstract class ListItemStatus<T> with _$ListItemStatus<T> {
  const factory ListItemStatus.empty() = _Empty<T>;
  const factory ListItemStatus.refreshing() = _Refreshing<T>;
  const factory ListItemStatus.loading() = _Loading<T>;
  const factory ListItemStatus.fetched() = _Fetched<T>;
  const factory ListItemStatus.error() = _Error<T>;
}
