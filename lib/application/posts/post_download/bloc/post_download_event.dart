part of 'post_download_bloc.dart';

abstract class PostDownloadEvent extends Equatable {
  const PostDownloadEvent();

  @override
  List<Object> get props => [];
}

class PostDownloadRequested extends PostDownloadEvent {
  final Post post;

  const PostDownloadRequested({
    @required this.post,
  });

  @override
  List<Object> get props => [post];
}

class PostDownloadServiceInitRequested extends PostDownloadEvent {
  final TargetPlatform platform;

  const PostDownloadServiceInitRequested({
    this.platform,
  });

  @override
  List<Object> get props => [platform];
}
