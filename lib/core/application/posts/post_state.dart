// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/error.dart';

class PostState<T> extends Equatable {
  const PostState({
    required this.data,
    required this.hasMore,
    required this.loading,
    required this.page,
    required this.refreshing,
    required this.error,
  });

  factory PostState.initial() => PostState(
        data: <T>[],
        hasMore: true,
        loading: false,
        page: 1,
        refreshing: false,
        error: null,
      );

  PostState<T> copyWith({
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    List<T>? data,
    BooruError? Function()? error,
  }) =>
      PostState(
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        refreshing: refreshing ?? this.refreshing,
        loading: loading ?? this.loading,
        data: data ?? this.data,
        error: error != null ? error() : this.error,
      );

  @override
  List<Object?> get props => [
        data,
        loading,
        refreshing,
        hasMore,
        page,
        error,
      ];

  final List<T> data;
  final bool hasMore;
  final bool loading;
  final int page;
  final bool refreshing;
  final BooruError? error;
}
