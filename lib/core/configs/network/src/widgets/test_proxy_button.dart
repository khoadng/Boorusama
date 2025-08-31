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
                            ? context.t.booru.network.proxy.test.success
                            : context.t.booru.network.proxy.test.failure,
                      ),
                    );
                  }
                }
              : null,
          child: switch (status) {
            TestProxyStatus.idle => Text(
              context.t.booru.network.proxy.test.state.idle,
            ),
            _ => Text(
              context.t.booru.network.proxy.test.state.testing,
            ),
          },
        ),
        if (status == TestProxyStatus.checkingPendingTimeout)
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${context.t.booru.network.proxy.test.state.slow} ',
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
