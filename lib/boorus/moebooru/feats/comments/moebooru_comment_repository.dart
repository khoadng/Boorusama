// Project imports:
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'moebooru_comment.dart';
import 'moebooru_comment_parser.dart';

abstract interface class MoebooruCommentRepository {
  Future<List<MoebooruComment>> getComments(int postId);
}

class MoebooruCommentRepositoryApi implements MoebooruCommentRepository {
  MoebooruCommentRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final MoebooruClient client;
  final BooruConfig booruConfig;

  @override
  Future<List<MoebooruComment>> getComments(int postId) => client
      .getComments(postId: postId)
      .then((value) => value.map(moebooruCommentDtoToMoebooruComment).toList())
      .catchError((e) => <MoebooruComment>[]);
}
