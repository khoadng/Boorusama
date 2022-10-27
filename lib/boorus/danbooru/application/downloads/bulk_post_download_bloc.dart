// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/error.dart';
import 'download_bloc.dart';

class BulkPostDownloadBloc extends DownloadBloc<String, Post> {
  BulkPostDownloadBloc({
    required super.downloader,
    required PostRepository postRepository,
    required PostCountRepository postCountRepository,
    required String? Function(BooruError e) errorTranslator,
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
          totalFetcher: (tag) => postCountRepository.count(tag.split(' ')),
          duplicateChecker: (post, files) => files.contains(post.md5),
          folderNameSelector: (tag) => tag,
          fileSizeSelector: (post) => post.fileSize,
          idSelector: (post) => post.id,
          filterSelector: (post) => post.viewable,
        );
}
