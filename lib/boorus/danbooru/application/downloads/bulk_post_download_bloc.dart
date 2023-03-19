// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/core/domain/error.dart';
import 'download_bloc.dart';

class BulkPostDownloadBloc extends DownloadBloc<String, DanbooruPost> {
  BulkPostDownloadBloc({
    required super.downloader,
    required DanbooruPostRepository postRepository,
    required PostCountRepository postCountRepository,
    required String? Function(BooruError e) errorTranslator,
    super.onDownloadDone,
  }) : super(
          itemFetcher: (page, tag, emit, state) async {
            try {
              return await postRepository.getPosts(
                tag,
                page,
                limit: 100,
                includeInvalid: true,
              );
            } catch (e) {
              if (e is BooruError) {
                emit(state.copyWith(errorMessage: errorTranslator(e)));
              }

              return [];
            }
          },
          totalFetcher: (tag) async {
            final count = await postCountRepository.count(tag.split(' '));

            return count ?? 0;
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
          filterSelector: (post) => !post.viewable,
          waitBetweenDownloadRequest: () =>
              Future.delayed(const Duration(milliseconds: 200)),
        );
}
