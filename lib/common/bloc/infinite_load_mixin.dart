// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class InfiniteLoadState<T, State> {
  int get page;
  bool get hasMore;
  bool get refreshing;
  bool get loading;
  List<T> get data;

  State copyLoadState({
    required int page,
    required bool hasMore,
    required bool refreshing,
    required bool loading,
    required List<T> data,
  });
}

mixin InfiniteLoadMixin<T, State> {
  int page = 1;
  bool hasMore = true;
  bool refreshing = false;
  bool loading = false;
  List<T> data = [];

  FutureOr<void> refresh({
    required Emitter<State> emitter,
    required InfiniteLoadState<T, State> Function() stateGetter,
    required Future<List<T>> Function(int page) refresh,
    void Function()? onRefreshStart,
    void Function()? onRefreshEnd,
    void Function(List<T> data)? onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      refreshing = true;
      page = 1;

      onRefreshStart?.call();
      emitter.call(stateGetter().copyLoadState(
        refreshing: refreshing,
        loading: loading,
        hasMore: hasMore,
        data: data,
        page: page,
      ));

      final d = await refresh(page);

      refreshing = false;

      onRefreshEnd?.call();

      data
        ..clear()
        ..addAll(d);

      onData?.call(data);

      emitter.call(stateGetter().copyLoadState(
        refreshing: refreshing,
        loading: loading,
        hasMore: hasMore,
        data: data,
        page: page,
      ));
    } catch (e, stackTrace) {
      onError?.call(e, stackTrace);
    }
  }

  FutureOr<void> fetch({
    required Emitter<State> emitter,
    required InfiniteLoadState<T, State> Function() stateGetter,
    required Future<List<T>> Function(int page) fetch,
    void Function()? onFetchStart,
    void Function(List<T> data)? onFetchEnd,
    void Function(List<T> data)? onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    if (!hasMore) return;

    try {
      loading = true;
      onFetchStart?.call();
      emitter.call(stateGetter().copyLoadState(
        refreshing: refreshing,
        loading: loading,
        hasMore: hasMore,
        data: data,
        page: page,
      ));

      final d = await fetch(page + 1);

      onData?.call(d);

      data.addAll(d);

      loading = false;
      page += 1;
      hasMore = d.isNotEmpty;

      onFetchEnd?.call(data);
      emitter.call(stateGetter().copyLoadState(
        refreshing: refreshing,
        loading: loading,
        hasMore: hasMore,
        data: data,
        page: page,
      ));
    } catch (e, stackTrace) {
      onError?.call(e, stackTrace);
    }
  }
}
