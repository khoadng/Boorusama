part of 'post_list_bloc.dart';

@freezed
abstract class PostListEvent with _$PostListEvent {
  const factory PostListEvent.loaded({@required List<Post> posts}) = _Loaded;
  const factory PostListEvent.moreLoaded({@required List<Post> posts}) =
      _LoadedMore;
}
