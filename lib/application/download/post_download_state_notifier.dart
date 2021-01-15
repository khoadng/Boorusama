import 'package:boorusama/application/download/file_name_generator.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'download_service.dart';
import 'i_download_service.dart';

part 'post_download_state.dart';
part 'post_download_state_notifier.freezed.dart';

class PostDownloadStateNotifier extends StateNotifier<PostDownloadState> {
  final IDownloadService _downloadService;
  final FileNameGenerator _fileNameGenerator;

  PostDownloadStateNotifier(ProviderReference ref)
      : _downloadService = ref.read(downloadServiceProvider),
        _fileNameGenerator = ref.read(fileNameGeneratorProvider),
        super(PostDownloadState.uninitialized());

  void init(TargetPlatform platform) async {
    await _downloadService.init(platform);
    state = const PostDownloadState.initialized();
  }

  void download(Post post) async {
    final url = post.isVideo
        ? post.normalImageUri.toString()
        : post.fullImageUri.toString();
    final filePath = _fileNameGenerator.generateFor(post, url);

    //TODO: handle permission denied
    state = const PostDownloadState.downloading();
    _downloadService.download(filePath, url);
    state = const PostDownloadState.success();
  }
}
