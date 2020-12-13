part of 'post_most_viewed_bloc.dart';

@freezed
abstract class PostMostViewedState with _$PostMostViewedState {
  const factory PostMostViewedState.empty() = _Empty;
  const factory PostMostViewedState.loading() = _Loading;
  const factory PostMostViewedState.additionalLoading() = _AdditionalLoading;
  const factory PostMostViewedState.fetched({@required List<Post> posts}) =
      _Fetched;
  const factory PostMostViewedState.additionalFetched(
      {@required List<Post> posts}) = _AdditionalFetched;
}
