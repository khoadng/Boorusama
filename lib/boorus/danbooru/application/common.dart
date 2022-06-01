import 'package:equatable/equatable.dart';

Future<void> TryAsync<T extends Object>({
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
    this.items = const [],
  });

  final LoadStatus status;
  final List<T> items;

  const AsyncLoadState.initial() : this._();
  const AsyncLoadState.loading() : this._();
  const AsyncLoadState.success(List<T> items)
      : this._(status: LoadStatus.success, items: items);
  const AsyncLoadState.failure() : this._(status: LoadStatus.failure);

  @override
  List<Object> get props => [status, items];
}
