// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/user_feedback.dart';
import 'user_feedback_converter.dart';

class UserFeedbackRepositoryApi implements DanbooruUserFeedbacksRepository {
  UserFeedbackRepositoryApi(this.client);

  final DanbooruClient client;

  @override
  Future<List<DanbooruUserFeedback>> getUserFeedbacks({
    required int userId,
  }) => client
      .getUserFeedbacks(userId: userId)
      .then(userFeedbackDtosToUserFeedbacks);
}
