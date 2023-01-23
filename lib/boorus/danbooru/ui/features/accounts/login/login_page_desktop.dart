// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/core/ui/warning_container.dart';
import 'widgets/login_box_widget.dart';

class LoginPageDesktop extends StatefulWidget {
  const LoginPageDesktop({
    super.key,
  });

  @override
  State<LoginPageDesktop> createState() => _LoginPageDesktopState();
}

class _LoginPageDesktopState extends State<LoginPageDesktop> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Login',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(
          thickness: 1.5,
        ),
        WarningContainer(
          contentBuilder: (context) => const Text('login.notice').tr(),
        ),
        const Center(
          child: LoginBox(),
        ),
      ],
    );
  }
}
