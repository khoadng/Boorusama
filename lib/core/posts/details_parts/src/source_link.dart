// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../foundation/url_launcher.dart';

class SourceLink extends ConsumerWidget {
  const SourceLink({
    required this.title,
    required this.actionBuilder,
    required this.name,
    super.key,
    this.url,
  });

  final Widget title;
  final String? url;
  final Widget Function() actionBuilder;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RemoveLeftPaddingOnLargeScreen(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        title: title,
        subtitle: url != null
            ? InkWell(
                onLongPress: () {
                  AppClipboard.copyAndToast(
                    context,
                    url.toString(),
                    message: context.t.generic.copied,
                  );
                },
                onTap: () {
                  if (url == null) return;
                  launchExternalUrl(
                    Uri.parse(url!),
                    launcher: ref.read(externalUrlLauncherProvider),
                  );
                },
                child: Text(
                  url.toString(),
                  maxLines: 1,
                  softWrap: false,
                  style: Kurumi.themeOf(context).textTheme.bodySmall,
                ),
              )
            : null,
        leading: CircleAvatar(
          backgroundColor: Kurumi.themeOf(
            context,
          ).colorScheme.tertiaryContainer,
          child: Center(
            child: Text(
              name.getFirstCharacter().toUpperCase(),
              style: TextStyle(
                color: Kurumi.themeOf(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),
        trailing: actionBuilder(),
      ),
    );
  }
}
