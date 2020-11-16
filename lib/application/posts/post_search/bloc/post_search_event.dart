part of 'post_search_bloc.dart';

@freezed
abstract class PostSearchEvent with _$PostSearchEvent {
  @Assert('query != null')
  @Assert('page != null')
  @Assert('page > 0', 'page cannot be negative')
  const factory PostSearchEvent.postSearched({
    @required String query,
    @required int page,
  }) = _PostSearched;
}
