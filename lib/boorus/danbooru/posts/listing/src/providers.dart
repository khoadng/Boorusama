// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/auth/types.dart';
import '../../../tags/edit/routes.dart';
import '../../post/types.dart';

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
