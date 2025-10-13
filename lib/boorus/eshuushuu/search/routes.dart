// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:booru_clients/eshuushuu.dart';

// Project imports:
import '../../../core/widgets/widgets.dart';
import 'pages.dart';

Future<TagType?> showTagTypeSelectionSheet(
  BuildContext context, {
  required String tagName,
}) {
  return showBooruModalBottomSheet<TagType>(
    context: context,
    builder: (context) => TagTypeSelectionSheet(
      tagName: tagName,
    ),
  );
}
