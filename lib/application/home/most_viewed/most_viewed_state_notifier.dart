import 'package:boorusama/application/home/post_view_model.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_name_generator.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'most_viewed_state.dart';
part 'most_viewed_state_notifier.freezed.dart';

class MostViewedStateNotifier extends StateNotifier<MostViewedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;
  final PostNameGenerator _postNameGenerator;

  MostViewedStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _postNameGenerator = ref.read(postNameGeneratorProvider),
        _settingRepository = ref.read(settingsProvider),
        super(MostViewedState.initial());

  void getPosts(DateTime date) async {
    try {
      state = MostViewedState.loading();

      final dtos = await _postRepository.getMostViewedPosts(date);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);
      final postVms = getPostVms(filteredPosts, _postNameGenerator);

      state = MostViewedState.fetched(
        posts: postVms,
        date: date,
      );
    } on DatabaseTimeOut catch (e) {
      state = MostViewedState.error(
          name: "Errors", message: "Something went wrong");
    }
  }

  void refresh(DateTime date) async {
    try {
      final dtos = await _postRepository.getMostViewedPosts(date);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);
      final postVms = getPostVms(filteredPosts, _postNameGenerator);

      state = MostViewedState.fetched(
        posts: postVms,
        date: date,
      );
    } on DatabaseTimeOut catch (e) {}
  }
}
