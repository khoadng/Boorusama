// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../proxy/proxy.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import 'test_proxy_notifier.dart';

class TestProxyButton extends ConsumerWidget {
  const TestProxyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    final notifier = ref.watch(testProxyProvider.notifier);
    final state = ref.watch(testProxyProvider);
    final status = state.status;

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        FilledButton(
          onPressed:
              proxySettings != null &&
                  proxySettings.isValid &&
                  status == TestProxyStatus.idle
              ? () async {
                  final success = await notifier.check(
                    proxySettings,
                  );

                  if (context.mounted) {
                    showSimpleSnackBar(
                      context: context,
                      duration: const Duration(seconds: 3),
                      content: Text(
                        success
                            ? 'Valid proxy settings'.hc
                            : 'Failed to connect to proxy, please check your settings and try again'
                                  .hc,
                      ),
                    );
                  }
                }
              : null,
          child: switch (status) {
            TestProxyStatus.idle => Text('Test Proxy'.hc),
            _ => Text('Checking...'.hc),
          },
        ),
        if (status == TestProxyStatus.checkingPendingTimeout)
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Slow response? '.hc,
                  ),
                  TextSpan(
                    text: context.t.generic.action.cancel,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        notifier.cancel();
                      },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
