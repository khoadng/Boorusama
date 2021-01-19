import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'download_service.dart';

part 'post_download_state.dart';
part 'post_download_state_notifier.freezed.dart';

class PostDownloadStateNotifier extends StateNotifier<PostDownloadState> {
  final IDownloadService _downloadService;

  PostDownloadStateNotifier(ProviderReference ref)
      : _downloadService = ref.read(downloadServiceProvider),
        super(PostDownloadState.uninitialized());

  void init(TargetPlatform platform) async {
    await _downloadService.init(platform);
    state = const PostDownloadState.initialized();
  }

  void download(Post post) async {
    //TODO: handle permission denied
    state = const PostDownloadState.downloading();
    _downloadService.download(post);
    state = const PostDownloadState.success();
  }
}
