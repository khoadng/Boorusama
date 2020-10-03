part of 'post_download_bloc.dart';

abstract class PostDownloadEvent extends Equatable {
  const PostDownloadEvent();

  @override
  List<Object> get props => [];
}

class PostDownloadRequested extends PostDownloadEvent {
  const PostDownloadRequested();

  @override
  List<Object> get props => [];
}
