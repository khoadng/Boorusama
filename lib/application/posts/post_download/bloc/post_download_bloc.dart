import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_download_event.dart';
part 'post_download_state.dart';

part 'post_download_bloc.freezed.dart';

class PostDownloadBloc extends Bloc<PostDownloadEvent, PostDownloadState> {
  final IDownloadService _downloadService;

  PostDownloadBloc(this._downloadService)
      : super(PostDownloadState.uninitialized());

  @override
  Stream<PostDownloadState> mapEventToState(
    PostDownloadEvent event,
  ) async* {
    yield* event.map(
        downloaded: (e) => _mapDownloadedToState(e),
        init: (e) => _mapInitToState(e));
  }

  Stream<PostDownloadState> _mapInitToState(_Init event) async* {
    await _downloadService.init(event.platform);
    yield const PostDownloadState.initialized();
  }

  Stream<PostDownloadState> _mapDownloadedToState(_Downloaded event) async* {
    //TODO: handle permission denied
    yield const PostDownloadState.downloading();
    //TODO: Shouldn't pass post and url at the same time, refactor later
    if (event.post.isVideo) {
      _downloadService.download(
          event.post, event.post.normalImageUri.toString());
    } else {
      _downloadService.download(event.post, event.post.fullImageUri.toString());
    }
  }
}
