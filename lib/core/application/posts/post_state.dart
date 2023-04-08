import 'package:equatable/equatable.dart';
import 'package:boorusama/core/domain/error.dart';

class PostState<T, E> extends Equatable {
  const PostState({
    required this.state,
    this.extra,
  });

  factory PostState.initial() => PostState(
        state: PostStateData<T>(
          data: <T>[],
          hasMore: true,
          loading: false,
          page: 1,
          refreshing: false,
          error: null,
        ),
      );

  final PostStateData<T> state;
  final E? extra;

  List<T> get data => state.data;
  bool get hasMore => state.hasMore;
  bool get loading => state.loading;
  int get page => state.page;
  bool get refreshing => state.refreshing;
  BooruError? get error => state.error;

  PostState<T, E> copyWith({
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    List<T>? data,
    BooruError? Function()? error,
    E? extra,
  }) =>
      PostState(
        state: PostStateData<T>(
          page: page ?? state.page,
          hasMore: hasMore ?? state.hasMore,
          refreshing: refreshing ?? state.refreshing,
          loading: loading ?? state.loading,
          data: data ?? state.data,
          error: error != null ? error() : state.error,
        ),
        extra: extra ?? this.extra,
      );

  @override
  List<Object?> get props => [
        state,
        extra,
      ];
}

class PostStateData<T> {
  const PostStateData({
    required this.data,
    required this.hasMore,
    required this.loading,
    required this.page,
    required this.refreshing,
    required this.error,
  });

  final List<T> data;
  final bool hasMore;
  final bool loading;
  final int page;
  final bool refreshing;
  final BooruError? error;
}
