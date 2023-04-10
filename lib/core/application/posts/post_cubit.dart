// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/posts/post_state.dart';
import 'package:boorusama/core/domain/error.dart';

abstract class PostCubit<T, E> extends Cubit<PostState<T, E>> {
  PostCubit({
    required this.initial,
  }) : super(initial);

  Future<List<T>> Function() get refresher;
  Future<List<T>> Function(int page) get fetcher;
  final PostState<T, E> initial;

  void refresh() async {
    if (state.refreshing) return;

    try {
      emit(state.copyWith(
        data: [],
        refreshing: true,
        hasMore: true,
        page: 1,
      ));

      final data = await refresher();

      emit(state.copyWith(
        refreshing: false,
        data: data,
        hasMore: data.isNotEmpty,
      ));
    } catch (e, s) {
      final isBooruError = e is BooruError;

      emit(state.copyWith(
        refreshing: false,
        data: [],
        hasMore: false,
        error: () => isBooruError ? e : null,
      ));

      if (!isBooruError) {
        Error.throwWithStackTrace(e, s);
      }
    }
  }

  void fetch() async {
    if (state.loading) return;

    try {
      emit(state.copyWith(
        loading: true,
      ));

      final data = await fetcher(state.page + 1);

      emit(state.copyWith(
        loading: false,
        hasMore: data.isNotEmpty,
        data: [
          ...state.data,
          ...data,
        ],
      ));
    } catch (e) {
      emit(state.copyWith(
        error: () => e is BooruError ? e : BooruError(error: e),
        hasMore: false,
      ));
    }
  }

  void reset() => emit(initial);
}
