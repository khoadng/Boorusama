// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/router.dart';

var _isDialogVisible = false;

void showSessionExpiredDialog({
  required VoidCallback onReLogin,
}) {
  if (_isDialogVisible) return;

  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) return;

  _isDialogVisible = true;

  showDialog<void>(
    context: context,
    routeSettings: const RouteSettings(name: 'session_expired'),
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.t.auth.login_expires),
      content: Text(dialogContext.t.auth.session_expired),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            MaterialLocalizations.of(dialogContext).cancelButtonLabel,
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onReLogin();
          },
          child: Text(dialogContext.t.auth.relogin),
        ),
      ],
    ),
  ).whenComplete(() => _isDialogVisible = false);
}
