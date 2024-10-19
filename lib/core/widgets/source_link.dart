// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/string.dart';

class SourceLink extends StatelessWidget {
  const SourceLink({
    super.key,
    required this.title,
    this.url,
    required this.actionBuilder,
    required this.name,
  });

  final Widget title;
  final String? url;
  final Widget Function() actionBuilder;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
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
                style: context.textTheme.bodySmall,
              ),
            )
          : null,
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            name.getFirstCharacter().toUpperCase(),
            style: TextStyle(
              color: context.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ),
      trailing: actionBuilder(),
    );
  }
}
