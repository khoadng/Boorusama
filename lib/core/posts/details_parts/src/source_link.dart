// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../foundation/url_launcher.dart';

class SourceLink extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    message: 'post.detail.copied'.tr(),
                  );
                },
                onTap: () {
                  if (url == null) return;
                  launchExternalUrl(Uri.parse(url!));
                },
                child: Text(
                  url.toString(),
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : null,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: Center(
            child: Text(
              name.getFirstCharacter().toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),
        trailing: actionBuilder(),
      ),
    );
  }
}
