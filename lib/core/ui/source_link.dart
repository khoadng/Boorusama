// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/i18n.dart';
import 'package:boorusama/utils/string_utils.dart';

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
              onLongPress: () =>
                  Clipboard.setData(ClipboardData(text: url.toString()))
                      .then((_) => showSimpleSnackBar(
                            duration: const Duration(seconds: 1),
                            context: context,
                            content: const Text('post.detail.copied').tr(),
                          )),
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
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Center(
          child: Text(name.getFirstCharacter().toUpperCase()),
        ),
      ),
      trailing: actionBuilder(),
    );
  }
}
