// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) =>
    showMaterialModalBottomSheet(
      duration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).backgroundColor,
      context: context,
      builder: builder,
    );

Future<T?> showActionListModalBottomSheet<T>({
  required BuildContext context,
  required List<Widget> children,
}) =>
    showAppModalBottomSheet(
      context: context,
      builder: (context) => ModalOptions(
        children: children,
      ),
    );

class ModalOptions extends StatelessWidget {
  const ModalOptions({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
