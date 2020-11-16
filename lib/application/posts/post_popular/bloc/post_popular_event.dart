part of 'post_popular_bloc.dart';

abstract class PostPopularEvent extends Equatable {
  const PostPopularEvent();

  @override
  List<Object> get props => [];
}

class PostPopularRequested extends PostPopularEvent {
  final DateTime date;
  final TimeScale scale;
  final int page;

  PostPopularRequested({
    @required this.date,
    @required this.scale,
    @required this.page,
  });

  @override
  List<Object> get props => [date, scale, page];
}

class LoadMorePopularPostRequested extends PostPopularEvent {
  final DateTime date;
  final TimeScale scale;
  final int page;

  LoadMorePopularPostRequested({
    @required this.date,
    @required this.scale,
    @required this.page,
  });

  @override
  List<Object> get props => [date, scale, page];
}
