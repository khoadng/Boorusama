// Project imports:
import 'package:boorusama/api/moebooru/moebooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/moebooru/feats/comments/moebooru_comment_parser.dart';
import 'moebooru_comment.dart';

abstract interface class MoebooruCommentRepository {
  Future<List<MoebooruComment>> getComments(int postId);
}

class MoebooruCommentRepositoryApi implements MoebooruCommentRepository {
  MoebooruCommentRepositoryApi({
    required this.api,
    required this.booruConfig,
  });

  final MoebooruApi api;
  final BooruConfig booruConfig;

  @override
  Future<List<MoebooruComment>> getComments(int postId) => api
      .getComments(booruConfig.login, booruConfig.apiKey, postId)
      .then(parseMoebooruComments)
      .catchError((e) => <MoebooruComment>[]);
}
