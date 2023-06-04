// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/error.dart';

Future<void> tryAsync<T extends Object?>({
  required Future<T> Function() action,
  required Future<void> Function(T data) onSuccess,
  void Function(StackTrace stackTrace, BooruError error)? onFailure,
  void Function(StackTrace stackTrace, Object error)? onUnknownFailure,
  void Function()? onLoading,
}) async {
  try {
    onLoading?.call();
    final data = await action();
    await onSuccess(data);
  } catch (e, stacktrace) {
    if (e is BooruError) {
      onFailure?.call(stacktrace, e);
    } else {
      onUnknownFailure?.call(stacktrace, e);
    }
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
