// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/i18n.dart';

class ParentChildTile extends StatelessWidget {
  const ParentChildTile({
    super.key,
    required this.data,
    required this.onTap,
    this.minVerticalPadding,
  });

  final ParentChildData data;
  final void Function(ParentChildData data) onTap;
  final double? minVerticalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Divider(),
        //WORKAROUND: for some reason, using tileColor in ListTile won't render properly.
        ColoredBox(
          color: Theme.of(context).cardColor,
          child: ListTile(
            minVerticalPadding: minVerticalPadding,
            dense: true,
            title: Text(data.description).tr(),
            trailing: Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () => onTap(data),
                child: const Text(
                  'post.detail.view',
                  style: TextStyle(color: Colors.white),
                ).tr(),
              ),
            ),
          ),
        ),
        const _Divider(),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hintColor,
      height: 1,
    );
  }
}
