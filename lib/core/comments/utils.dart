// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required int postId,
  RouteSettings? settings,
  required Widget Function(BuildContext context, bool useAppBar) builder,
}) =>
    Screen.of(context).size == ScreenSize.small
        ? showMaterialModalBottomSheet<T>(
            context: context,
            settings: settings,
            duration: AppDurations.bottomSheet,
            builder: (context) => builder(context, true),
          )
        : showSideSheetFromRight(
            settings: settings,
            width: context.screenWidth * 0.41,
            body: Container(
              color: Colors.transparent,
              padding:
                  EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
              child: Column(
                children: [
                  Container(
                    height: kToolbarHeight * 0.8,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
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
                          style: context.textTheme.titleLarge,
                        ).tr(),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            onTap: context.navigator.pop,
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
