// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';

class GelbooruBulkPostDownloadBloc extends DownloadBloc<String, Post> {
  GelbooruBulkPostDownloadBloc({
    required super.downloader,
    required PostRepository postRepository,
    required String? Function(BooruError e) errorTranslator,
    super.onDownloadDone,
  }) : super(
          itemFetcher: (page, tag, emit, state) async {
            try {
              return await postRepository.getPostsFromTags(
                tag,
                page,
                limit: 100,
              );
            } catch (e) {
              if (e is BooruError) {
                emit(state.copyWith(errorMessage: errorTranslator(e)));
              }

              return [];
            }
          },
          totalFetcher: (tag) async {
            return -1;
          },
          duplicateChecker: (post, storagePath) {
            final fileExt = extension(post.downloadUrl);
            final path = join(
              storagePath,
              '${post.md5}$fileExt',
            );

            return File(path).existsSync();
          },
          fileSizeSelector: (post) => post.fileSize,
          idSelector: (post) => post.id,
          filterSelector: (post) => false,
          waitBetweenDownloadRequest: () =>
              Future.delayed(const Duration(milliseconds: 200)),
        );
}
