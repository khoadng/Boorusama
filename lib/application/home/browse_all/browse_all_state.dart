part of 'browse_all_state_notifier.dart';

@freezed
abstract class BrowseAllState with _$BrowseAllState {
  const factory BrowseAllState.initial() = _Initial;
  const factory BrowseAllState.loading() = _Loading;

  const factory BrowseAllState.fetched({
    @required List<Post> posts,
    @required int page,
    @required String query,
  }) = _Fetched;
}
