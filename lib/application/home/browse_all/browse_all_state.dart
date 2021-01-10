part of 'browse_all_bloc.dart';

@freezed
abstract class BrowseAllState with _$BrowseAllState {
  const factory BrowseAllState({
    @required List<Post> posts,
    @required String query,
    @required int page,
    @required bool isRefreshing,
    @required bool isLoadingNew,
    @required bool isLoadingMore,
    @required bool isSearching,
    @required @nullable Error error,
  }) = _BrowseAllState;

  factory BrowseAllState.initial() => BrowseAllState(
        posts: <Post>[],
        query: "",
        page: 1,
        isRefreshing: false,
        isLoadingNew: false,
        isLoadingMore: false,
        isSearching: false,
        error: null,
      );
}
