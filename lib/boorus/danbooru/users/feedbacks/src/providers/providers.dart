// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../danbooru_provider.dart';
import '../data/user_feedback_repository_api.dart';
import '../types/user_feedback.dart';

final danbooruUserFeedbackRepoProvider =
    Provider.family<DanbooruUserFeedbacksRepository, BooruConfigAuth>(
        (ref, config) {
  return UserFeedbackRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});
