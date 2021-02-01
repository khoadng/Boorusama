// Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';

class NoImageFilterDecorator implements IPostRepository {
  NoImageFilterDecorator({
    @required IPostRepository postRepository,
  }) : _postRepository = postRepository;

  final IPostRepository _postRepository;

  @override
  Future<List<PostDto>> getCuratedPosts(
      DateTime date, int page, TimeScale scale) async {
    final dtos = await _postRepository.getCuratedPosts(date, page, scale);
    return dtos
        .where((dto) =>
            dto.file_url != null &&
            dto.preview_file_url != null &&
            dto.large_file_url != null)
        .toList();
  }

  @override
  Future<List<PostDto>> getMostViewedPosts(DateTime date) async {
    final dtos = await _postRepository.getMostViewedPosts(date);
    return dtos
        .where((dto) =>
            dto.file_url != null &&
            dto.preview_file_url != null &&
            dto.large_file_url != null)
        .toList();
  }

  @override
  Future<List<PostDto>> getPopularPosts(
      DateTime date, int page, TimeScale scale) async {
    final dtos = await _postRepository.getPopularPosts(date, page, scale);
    return dtos
        .where((dto) =>
            dto.file_url != null &&
            dto.preview_file_url != null &&
            dto.large_file_url != null)
        .toList();
  }

  @override
  Future<List<PostDto>> getPosts(
    String tagString,
    int page, {
    int limit = 100,
    CancelToken cancelToken,
  }) async {
    final dtos = await _postRepository.getPosts(tagString, page,
        limit: limit, cancelToken: cancelToken);
    return dtos
        .where((dto) =>
            dto.file_url != null &&
            dto.preview_file_url != null &&
            dto.large_file_url != null)
        .toList();
  }
}
