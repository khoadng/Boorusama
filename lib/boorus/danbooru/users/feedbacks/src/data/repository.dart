// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/user_feedback.dart';
import 'parser.dart';

class UserFeedbackRepositoryApi implements DanbooruUserFeedbacksRepository {
  UserFeedbackRepositoryApi(this.client);

  final DanbooruClient client;

  @override
  Future<List<DanbooruUserFeedback>> getUserFeedbacks({
    required int userId,
    int? limit,
    int? page,
  }) => client
      .getUserFeedbacks(
        userId: userId,
        limit: limit,
        page: page,
      )
      .then(userFeedbackDtosToUserFeedbacks);
}
