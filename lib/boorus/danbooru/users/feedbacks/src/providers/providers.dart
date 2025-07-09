// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../client_provider.dart';
import '../data/repository.dart';
import '../types/user_feedback.dart';

final danbooruUserFeedbackRepoProvider =
    Provider.family<DanbooruUserFeedbacksRepository, BooruConfigAuth>((
      ref,
      config,
    ) {
      return UserFeedbackRepositoryApi(
        ref.watch(danbooruClientProvider(config)),
      );
    });
