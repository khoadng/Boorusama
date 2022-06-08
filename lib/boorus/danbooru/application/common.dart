// Package imports:
import 'package:equatable/equatable.dart';

Future<void> tryAsync<T extends Object?>({
  required Future<T> Function() action,
  required void Function(T data) onSuccess,
  void Function(StackTrace stackTrace, Object error)? onFailure,
  void Function()? onLoading,
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
    this.data,
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
