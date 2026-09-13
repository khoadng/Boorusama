// Package imports:
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

Future<void> pushSettingsPage(
  BuildContext context, {
  required String name,
  required WidgetBuilder builder,
}) {
  final host = context.findAncestorWidgetOfExactType<KurumiDialog>();
  if (host == null) {
    return Navigator.of(context).push<void>(
      CupertinoPageRoute(
        settings: RouteSettings(name: name),
        builder: builder,
      ),
    );
  }
  return Navigator.of(context).push<void>(
    RawDialogRoute(
      settings: RouteSettings(name: name),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) => KurumiDialog(
        width: host.width,
        height: host.height,
        padding: host.padding,
        color: host.color,
        borderRadius: host.borderRadius,
        dismissible: host.dismissible,
        semanticLabel: host.semanticLabel,
        child: Builder(builder: builder),
      ),
    ),
  );
}
