// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import '../models/parent_child_data.dart';

class ParentChildTile extends StatelessWidget {
  const ParentChildTile({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  final ParentChildData data;
  final void Function(ParentChildData data) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Divider(),
        //WORKAROUND: for some reason, using tileColor in ListTile won't render properly.
        Container(
          color: Theme.of(context).cardColor,
          child: ListTile(
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
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hintColor,
      height: 1,
    );
  }
}
