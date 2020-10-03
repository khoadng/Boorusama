part of 'post_download_bloc.dart';

abstract class PostDownloadState extends Equatable {
  const PostDownloadState();

  @override
  List<Object> get props => [];
}

class PostDownloadInitial extends PostDownloadState {}

class PostDownloading extends PostDownloadState {}

class PostDownloaded extends PostDownloadState {}
