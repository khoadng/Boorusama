// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../foundation/display.dart';
import '../foundation/widgets/side_sheet.dart';

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required int postId,
  required Widget Function(BuildContext context, bool useAppBar) builder,
  RouteSettings? settings,
}) =>
    Screen.of(context).size == ScreenSize.small
        ? Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => builder(context, true),
            ),
          )
        : showSideSheetFromRight(
            settings: settings,
            width: MediaQuery.sizeOf(context).width * 0.41,
            body: Container(
              color: Colors.transparent,
              padding:
                  EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
              child: Column(
                children: [
                  Container(
                    height: kToolbarHeight * 0.8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'comment.comments',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).tr(),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            onTap: Navigator.of(context).pop,
                            child: const Icon(Symbols.close),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: builder(context, false),
                  ),
                ],
              ),
            ),
            context: context,
          );

String parse(
  String text,
  RegExp pattern,
  String Function(Match match) replace,
) =>
    text.replaceAllMapped(pattern, replace);

String linkify({
  required String? title,
  required String? address,
  bool underline = false,
}) {
  String underline_() => underline ? '' : 'style="text-decoration:none"';

  return '<a href="$address" ${underline_()}>$title</a>';
}
