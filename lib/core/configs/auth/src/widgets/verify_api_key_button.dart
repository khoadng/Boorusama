// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../widgets/widgets.dart';

class VerifyApiKeyButton extends StatelessWidget {
  const VerifyApiKeyButton({
    required this.loginController,
    required this.apiKeyController,
    required this.onVerify,
    super.key,
  });

  final TextEditingController loginController;
  final TextEditingController apiKeyController;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiValueListenableBuilder2(
      first: loginController,
      second: apiKeyController,
      builder: (context, login, apiKey) {
        final isEnabled = login.text.isNotEmpty && apiKey.text.isNotEmpty;

        return GestureDetector(
          onTap: isEnabled ? onVerify : null,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEnabled
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
            ),
            child: Text(
              context.t.generic.action.verify,
              style: TextStyle(
                fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                color: isEnabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
