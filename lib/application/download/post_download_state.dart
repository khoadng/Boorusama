part of 'post_download_state_notifier.dart';

@freezed
abstract class PostDownloadState with _$PostDownloadState {
  const factory PostDownloadState.uninitialized() = _Uninitialized;
  const factory PostDownloadState.initialized() = _Initilized;
  const factory PostDownloadState.downloading() = _Downloading;
  const factory PostDownloadState.success() = _Success;
  const factory PostDownloadState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
