part of 'post_curated_bloc.dart';

@freezed
abstract class PostCuratedState with _$PostCuratedState {
  const factory PostCuratedState.empty() = _Empty;
  const factory PostCuratedState.loading() = _Loading;
  const factory PostCuratedState.additionalLoading() = _AdditionalLoading;
  const factory PostCuratedState.fetched({@required List<Post> posts}) =
      _Fetched;
  const factory PostCuratedState.additionalFetched(
      {@required List<Post> posts}) = _AdditionalFetched;
}
