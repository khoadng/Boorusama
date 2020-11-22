part of 'post_search_bloc.dart';

@freezed
abstract class PostSearchState with _$PostSearchState {
  const factory PostSearchState.idle() = _Idle;
  const factory PostSearchState.loading(String query, int page) = _Loading;
  const factory PostSearchState.success(
      List<Post> posts, String query, int page) = _Success;
  const factory PostSearchState.error(String error, String message) = _Error;
}
