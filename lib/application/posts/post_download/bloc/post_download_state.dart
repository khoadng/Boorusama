part of 'post_download_bloc.dart';

@freezed
abstract class PostDownloadState with _$PostDownloadState {
  const factory PostDownloadState.uninitialized() = _Uninitialized;
  const factory PostDownloadState.initialized() = _Initialized;
  const factory PostDownloadState.downloading() = _Downloading;
  const factory PostDownloadState.done() = _Done;
}
