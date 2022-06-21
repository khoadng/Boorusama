// Package imports:
import 'package:equatable/equatable.dart';

Future<void> tryAsync<T extends Object?>({
  required Future<T> Function() action,
  required Future<void> Function(T data) onSuccess,
  void Function(StackTrace stackTrace, Object error)? onFailure,
  void Function()? onLoading,
}) async {
  try {
    onLoading?.call();
    final data = await action();
    await onSuccess(data);
  } catch (e, stacktrace) {
    onFailure?.call(stacktrace, e);
  }
}

enum LoadStatus { initial, loading, success, failure }

class AsyncLoadState<T extends Object> extends Equatable {
  const AsyncLoadState.success(T data)
      : this._(status: LoadStatus.success, data: data);
  const AsyncLoadState.failure() : this._(status: LoadStatus.failure);
  const AsyncLoadState.loading() : this._();

  const AsyncLoadState.initial() : this._();
  const AsyncLoadState._({
    this.status = LoadStatus.initial,
    this.data,
  });

  final LoadStatus status;
  final T? data;

  @override
  List<Object?> get props => [status, data];
}
