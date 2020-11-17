part of 'post_popular_bloc.dart';

@freezed
abstract class PostPopularState with _$PostPopularState {
  const factory PostPopularState.empty() = _Empty;
  const factory PostPopularState.loading() = _Loading;
  const factory PostPopularState.additionalLoading() = _AdditionalLoading;
  const factory PostPopularState.fetched({@required List<Post> posts}) =
      _Fetched;
  const factory PostPopularState.additionalFetched(
      {@required List<Post> posts}) = _AdditionalFetched;
}
