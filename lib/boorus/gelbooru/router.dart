// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/flutter.dart';
import 'pages/gelbooru_artist_page.dart';

void goToGelbooruArtistPage(
  WidgetRef ref,
  BuildContext context,
  String artist,
) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => GelbooruArtistPage(
      artistName: artist,
    ),
  ));
}

void goToGelbooruCommentsPage(
  BuildContext context,
  int postId,
) {
  showMaterialModalBottomSheet(
    context: context,
    duration: const Duration(milliseconds: 250),
    builder: (context) => GelbooruCommentPage(postId: postId),
  );
}
