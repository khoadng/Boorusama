part of 'post_list_bloc.dart';

@freezed
abstract class PostListState with _$PostListState {
  const factory PostListState.empty() = _Empty;
  const factory PostListState.fetched({@required List<Post> posts}) = _Fetch;
  const factory PostListState.fetchedMore({@required List<Post> posts}) =
      _FetchedMore;
  const factory PostListState.error({
    @required String error,
    String message,
  }) = _Error;
}
