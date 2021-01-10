part of 'browse_all_bloc.dart';

@freezed
abstract class BrowseAllEvent with _$BrowseAllEvent {
  const factory BrowseAllEvent.started({
    String initialQuery,
  }) = _Started;
  const factory BrowseAllEvent.refreshed() = _Refreshed;
  const factory BrowseAllEvent.loadedMore() = _LoadedMore;

  @Assert('query != null')
  const factory BrowseAllEvent.searched({
    @required String query,
  }) = _Searched;
}
