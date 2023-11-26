// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

final _aspectRatio = [
  ...List<double>.generate(20, (_) => 0.71),
  ...List<double>.generate(6, (_) => 1),
  ...List<double>.generate(5, (_) => 0.75),
  ...List<double>.generate(4, (_) => 0.7),
  ...List<double>.generate(3, (_) => 1.33),
  ...List<double>.generate(3, (_) => 0.72),
  ...List<double>.generate(3, (_) => 0.67),
  ...List<double>.generate(3, (_) => 1.41),
  ...List<double>.generate(2, (_) => 0.8),
  ...List<double>.generate(2, (_) => 0.68),
  ...List<double>.generate(2, (_) => 0.69),
  ...List<double>.generate(2, (_) => 0.73),
  ...List<double>.generate(2, (_) => 1.78),
  ...List<double>.generate(2, (_) => 0.74),
  ...List<double>.generate(2, (_) => 0.77),
  ...List<double>.generate(1, (_) => 0.65),
  ...List<double>.generate(1, (_) => 0.83),
  ...List<double>.generate(1, (_) => 0.63),
  ...List<double>.generate(1, (_) => 0.76),
  ...List<double>.generate(1, (_) => 0.78),
  ...List<double>.generate(1, (_) => 0.66),
  ...List<double>.generate(1, (_) => 0.64),
  ...List<double>.generate(1, (_) => 1.42),
  ...List<double>.generate(1, (_) => 0.56),
  ...List<double>.generate(1, (_) => 0.79),
  ...List<double>.generate(1, (_) => 0.81),
  ...List<double>.generate(1, (_) => 0.62),
  ...List<double>.generate(1, (_) => 0.6),
  ...List<double>.generate(1, (_) => 0.82),
  ...List<double>.generate(1, (_) => 1.25),
  ...List<double>.generate(1, (_) => 0.86),
  ...List<double>.generate(1, (_) => 0.88),
  ...List<double>.generate(1, (_) => 0.61),
  ...List<double>.generate(1, (_) => 0.85),
  ...List<double>.generate(1, (_) => 0.84),
  ...List<double>.generate(1, (_) => 0.89),
  ...List<double>.generate(1, (_) => 1.4),
  ...List<double>.generate(1, (_) => 1.5),
  ...List<double>.generate(1, (_) => 0.59),
  ...List<double>.generate(1, (_) => 0.87),
  ...List<double>.generate(1, (_) => 0.58),
  ...List<double>.generate(1, (_) => 0.9),
  ...List<double>.generate(1, (_) => 1.6),
  ...List<double>.generate(1, (_) => 0.57),
  ...List<double>.generate(1, (_) => 0.91),
  ...List<double>.generate(1, (_) => 0.92),
  ...List<double>.generate(1, (_) => 1.43),
  ...List<double>.generate(1, (_) => 0.93),
  ...List<double>.generate(1, (_) => 0.94),
  ...List<double>.generate(1, (_) => 1.2),
  ...List<double>.generate(1, (_) => 0.95),
  ...List<double>.generate(1, (_) => 0.55),
  ...List<double>.generate(1, (_) => 0.5),
  ...List<double>.generate(1, (_) => 0.96),
];

String getImageUrlForDisplay(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.thumbnailImageUrl;
  if (quality == ImageQuality.low) return post.thumbnailImageUrl;

  return post.sampleImageUrl;
}

Widget createRandomPlaceholderContainer(
  BuildContext context, {
  BorderRadius? borderRadius,
}) {
  return AspectRatio(
    aspectRatio: _aspectRatio[Random().nextInt(_aspectRatio.length - 1)],
    child: ImagePlaceHolder(
      borderRadius: borderRadius,
    ),
  );
}

String generateCopyrightOnlyReadableName(List<String> copyrightTags) {
  final copyrights = copyrightTags;
  final copyright = copyrights.isEmpty ? 'original' : copyrights.first;

  final remainedCopyrightString = copyrights.skip(1).isEmpty
      ? ''
      : ' and ${copyrights.skip(1).length} more';

  return '$copyright$remainedCopyrightString';
}

String generateCharacterOnlyReadableName(List<String> characterTags) {
  final charaters = characterTags;
  final cleanedCharacterList = [];

  // Remove copyright string in character name
  for (final character in charaters) {
    final index = character.indexOf('(');
    var cleanedName = character;

    if (index > 0) {
      cleanedName = character.substring(0, index - 1);
    }

    if (!cleanedCharacterList.contains(cleanedName)) {
      cleanedCharacterList.add(cleanedName);
    }
  }

  final characterString = cleanedCharacterList.take(3).join(', ');
  final remainedCharacterString = cleanedCharacterList.skip(3).isEmpty
      ? ''
      : ' and ${cleanedCharacterList.skip(3).length} more';

  return '${characterString.isEmpty ? 'original' : characterString}$remainedCharacterString';
}

Future<bool> launchExternalUrl(
  Uri url, {
  void Function()? onError,
  LaunchMode? mode,
}) async {
  if (!await launchUrl(
    url,
    mode: mode ?? LaunchMode.externalApplication,
  )) {
    onError?.call();

    return false;
  }

  return true;
}

Future<bool> launchExternalUrlString(
  String url, {
  void Function()? onError,
  LaunchMode? mode,
}) async {
  if (!await launchUrlString(
    url,
    mode: mode ?? LaunchMode.externalApplication,
  )) {
    onError?.call();

    return false;
  }

  return true;
}

void showSimpleSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarBehavior? behavior,
  SnackBarAction? action,
}) {
  final snackBarBehavior = behavior ?? SnackBarBehavior.floating;
  final snackbar = SnackBar(
    action: action,
    behavior: snackBarBehavior,
    duration: duration ?? const Duration(seconds: 6),
    elevation: 6,
    width: _calculateSnackBarWidth(context, snackBarBehavior),
    content: content,
  );
  context.scaffoldMessenger.showSnackBar(snackbar);
}

double? _calculateSnackBarWidth(
  BuildContext context,
  SnackBarBehavior behavior,
) {
  if (behavior == SnackBarBehavior.fixed) return null;
  final width = context.screenWidth;

  return width > 400 ? 400 : width;
}

Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? height,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  return Screen.of(context).size != ScreenSize.small
      ? showGeneralDialog<T>(
          context: context,
          routeSettings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        )
      : showBarModalBottomSheet<T>(
          context: context,
          settings: settings,
          barrierColor: Colors.black45,
          backgroundColor: backgroundColor ?? Colors.transparent,
          builder: (context) => ConditionalParentWidget(
            condition: !expand,
            child: builder(context),
            conditionalBuilder: (child) => SizedBox(
              height: height,
              child: child,
            ),
          ),
        );
}

Future<bool> launchWikiPage(String endpoint, String tag) => launchExternalUrl(
      Uri.parse('$endpoint/wiki_pages/$tag'),
      mode: LaunchMode.platformDefault,
    );

List<Widget> noteOverlayBuilderDelegate(BoxConstraints constraints, Post post,
        NotesControllerState noteState) =>
    [
      if (noteState.enableNotes)
        ...noteState.notes
            .map((e) => e.adjustNoteCoordFor(
                  post,
                  widthConstraint: constraints.maxWidth,
                  heightConstraint: constraints.maxHeight,
                ))
            .map((e) => PostNote(
                  coordinate: e.coordinate,
                  content: e.content,
                )),
    ];

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
            duration: const Duration(milliseconds: 250),
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
                            child: const Icon(Icons.close),
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
