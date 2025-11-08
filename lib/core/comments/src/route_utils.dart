// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../../foundation/widgets/side_sheet.dart';
import 'widgets/comment_side_sheet_container.dart';

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required Widget Function(BuildContext context, bool useAppBar) builder,
  RouteSettings? settings,
}) => Screen.of(context).size == ScreenSize.small
    ? Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => builder(context, true),
        ),
      )
    : showSideSheetFromRight(
        settings: settings,
        width: MediaQuery.sizeOf(context).width * 0.41,
        body: CommentSideSheetContainer(
          builder: builder,
        ),
        context: context,
      );
