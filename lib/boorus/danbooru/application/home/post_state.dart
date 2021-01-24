import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_state.freezed.dart';

@freezed
abstract class PostState with _$PostState {
  const factory PostState.empty() = _Empty;
  const factory PostState.refreshing() = _Refreshing;
  const factory PostState.loading() = _Loading;
  const factory PostState.fetched() = _Fetched;
  const factory PostState.error() = _Error;
}
