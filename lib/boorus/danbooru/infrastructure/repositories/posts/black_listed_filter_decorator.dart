// Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';

class BlackListedFilterDecorator implements IPostRepository {
  BlackListedFilterDecorator(
      {@required IPostRepository postRepository,
      @required Future<ISettingRepository> settingRepository})
      : _postRepository = postRepository,
        _settingRepository = settingRepository;

  final IPostRepository _postRepository;
  final Future<ISettingRepository> _settingRepository;

  @override
  Future<List<PostDto>> getCuratedPosts(
      DateTime date, int page, TimeScale scale) async {
    final dtos = await _postRepository.getCuratedPosts(date, page, scale);
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();

    final tagRule = settings.blacklistedTags.split("\n");

    final posts = dtos
        .where((dto) => dto.tag_string
            .split(' ')
            .toSet()
            .intersection(tagRule.toSet())
            .isEmpty)
        .toList();

    for (var dto in dtos) {
      //TODO: should handle tag combination instead of a single tag
      for (var tags in tagRule) {
        if (tags.split(" ").length == 1) {
          if (dto.tag_string.split(' ').contains(tags)) {
            posts.add(dto);
          }
        }
      }
      posts.add(dto);
    }

    return posts;
  }

  @override
  Future<List<PostDto>> getMostViewedPosts(DateTime date) async {
    final dtos = await _postRepository.getMostViewedPosts(date);
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();

    final tagRule = settings.blacklistedTags.split("\n");
    final posts = dtos
        .where((dto) => dto.tag_string
            .split(' ')
            .toSet()
            .intersection(tagRule.toSet())
            .isEmpty)
        .toList();

    return posts;
  }

  @override
  Future<List<PostDto>> getPopularPosts(
      DateTime date, int page, TimeScale scale) async {
    final dtos = await _postRepository.getPopularPosts(date, page, scale);
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();

    final tagRule = settings.blacklistedTags.split("\n");

    final posts = dtos
        .where((dto) => dto.tag_string
            .split(' ')
            .toSet()
            .intersection(tagRule.toSet())
            .isEmpty)
        .toList();

    return posts;
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
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();

    final tagRule = settings.blacklistedTags.split("\n");

    final posts = dtos
        .where((dto) => dto.tag_string
            .split(' ')
            .toSet()
            .intersection(tagRule.toSet())
            .isEmpty)
        .toList();

    return posts;
  }
}
