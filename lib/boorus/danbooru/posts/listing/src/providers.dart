// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import '../../../_shared/guard_login.dart';
import '../../post/post.dart';

extension DanbooruVoteX on WidgetRef {
  void danbooruEdit(DanbooruPost post) {
    guardLogin(this, () {
      goToTagEditPage(
        context,
        post: post,
      );
    });
  }
}
