// Package imports:
import 'package:equatable/equatable.dart';

Future<void> TryAsync<T extends Object?>({
  required Future<T> action(),
  required void onSuccess(T data),
  void onFailure(StackTrace stackTrace, Object error)?,
  void onLoading()?,
}) async {
  try {
    onLoading?.call();
    var data = await action();
    onSuccess(data);
  } catch (e, stacktrace) {
    onFailure?.call(stacktrace, e);
  }
}

enum LoadStatus { initial, loading, success, failure }

class AsyncLoadState<T extends Object> extends Equatable {
  const AsyncLoadState._({
    this.status = LoadStatus.initial,
    this.data = null,
  });

  final LoadStatus status;
  final T? data;

  const AsyncLoadState.initial() : this._();
  const AsyncLoadState.loading() : this._();
  const AsyncLoadState.success(T data)
      : this._(status: LoadStatus.success, data: data);
  const AsyncLoadState.failure() : this._(status: LoadStatus.failure);

  @override
  List<Object?> get props => [status, data];
}
