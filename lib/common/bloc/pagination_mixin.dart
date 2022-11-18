// Dart imports:
import 'dart:async';

// Project imports:
import 'infinite_load_mixin.dart';

abstract class PaginationLoadState<T, State> {
  int get page;
  bool get loading;
  List<T> get data;

  State copyPaginationState({
    required int page,
    required bool loading,
    required List<T> data,
  });
}

mixin PaginationMixin<T, State> {
  int currentPage = 1;
  bool loading = false;
  List<T> data = [];

  FutureOr<void> load({
    EmitConfig<T, State, PaginationLoadState<T, State>>? emit,
    required int page,
    required Future<List<T>> Function(int page) fetch,
    void Function()? onFetchStart,
    void Function(List<T> data)? onFetchEnd,
    void Function(List<T> data)? onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      loading = true;
      onFetchStart?.call();
      if (emit != null) {
        emit.emitter(emit.stateGetter().copyPaginationState(
              loading: loading,
              data: data,
              page: page,
            ));
      }

      final d = await fetch(page);

      onData?.call(d);

      data = d;

      loading = false;
      currentPage = page;

      onFetchEnd?.call(data);
      if (emit != null) {
        emit.emitter(emit.stateGetter().copyPaginationState(
              loading: loading,
              data: data,
              page: page,
            ));
      }
    } catch (e, stackTrace) {
      onError?.call(e, stackTrace);
    }
  }
}
