import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'post_download_event.dart';
part 'post_download_state.dart';

class PostDownloadBloc extends Bloc<PostDownloadEvent, PostDownloadState> {
  final IDownloadService _downloadService;

  PostDownloadBloc(this._downloadService) : super(PostDownloadInitial());

  @override
  Stream<PostDownloadState> mapEventToState(
    PostDownloadEvent event,
  ) async* {
    if (event is PostDownloadServiceInitRequested) {
      await _downloadService.init(event.platform);
    } else if (event is PostDownloadRequested) {
      //TODO: handle permission denied
      yield PostDownloading();
      _downloadService.download(event.post.fullImageUri.toString());
    }
  }
}
