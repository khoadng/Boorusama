part of 'post_download_bloc.dart';

@freezed
abstract class PostDownloadEvent with _$PostDownloadEvent {
  const factory PostDownloadEvent.downloaded({@required Post post}) =
      _Downloaded;
  const factory PostDownloadEvent.init({@required TargetPlatform platform}) =
      _Init;
}
