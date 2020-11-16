part of 'post_popular_bloc.dart';

abstract class PostPopularState extends Equatable {
  const PostPopularState();

  @override
  List<Object> get props => [];
}

class PostPopularEmpty extends PostPopularState {}

class PostPopularLoading extends PostPopularState {}

class PostPopularFetched extends PostPopularState {
  final List<Post> posts;

  PostPopularFetched({
    @required this.posts,
  });

  @override
  List<Object> get props => [posts];
}

class AdditionalPostPopularLoading extends PostPopularState {}

class AdditionalPostPopularFetched extends PostPopularState {
  final List<Post> posts;

  AdditionalPostPopularFetched({
    @required this.posts,
  });

  @override
  List<Object> get props => [posts];
}
