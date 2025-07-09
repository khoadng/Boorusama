// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/auth/auth.dart';
import '../../../tags/edit/routes.dart';
import '../../post/post.dart';

extension DanbooruVoteX on WidgetRef {
  void danbooruEdit(DanbooruPost post) {
    guardLogin(this, () {
      goToTagEditPage(
        this,
        post: post,
      );
    });
  }
}
