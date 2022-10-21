// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/common/string_utils.dart';
import 'package:boorusama/core/core.dart';

class SourceLink extends StatelessWidget {
  const SourceLink({
    Key? key,
    required this.title,
    required this.url,
    required this.actionBuilder,
    required this.name,
  }) : super(key: key);

  final Widget title;
  final String? url;
  final Widget Function() actionBuilder;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: title,
      subtitle: InkWell(
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
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Center(
          child: Text(name.getFirstCharacter().toUpperCase()),
        ),
      ),
      trailing: actionBuilder(),
    );
  }
}
