// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../http/src/dio/dio.dart';
import '../../../proxy/proxy.dart';
import '../../../widgets/widgets.dart';
import '../../manage.dart';
import 'providers.dart';

class BooruConfigNetworkView extends ConsumerWidget {
  const BooruConfigNetworkView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EnableProxySwitch(),
          ProxyTypeOptionTile(),
          SizedBox(height: 12),
          ProxyHostInput(),
          SizedBox(height: 12),
          ProxyPortInput(),
          SizedBox(height: 12),
          ProxyUsernameInput(),
          SizedBox(height: 12),
          ProxyPasswordInput(),
          SizedBox(height: 12),
          TestProxyButton(),
        ],
      ),
    );
  }
}

class ProxyHostInput extends ConsumerStatefulWidget {
  const ProxyHostInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProxyHostInputState();
}

class _ProxyHostInputState extends ConsumerState<ProxyHostInput> {
  @override
  Widget build(BuildContext context) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    return BooruTextFormField(
      initialValue: proxySettings?.host,
      onChanged: (value) {
        ref.editNotifier
            .updateProxySettings(proxySettings?.copyWith(host: value));
      },
      decoration: const InputDecoration(
        labelText: 'Host or IP (*)',
        hintText: 'proxy.host.com or 123.456.789.0',
      ),
    );
  }
}

class ProxyPortInput extends ConsumerStatefulWidget {
  const ProxyPortInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProxyPortInputState();
}

class _ProxyPortInputState extends ConsumerState<ProxyPortInput> {
  @override
  Widget build(BuildContext context) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    final initialValue = proxySettings?.port.toString() ?? '';

    return BooruTextFormField(
      initialValue: initialValue == '0' ? '' : initialValue,
      onChanged: (value) {
        final port = int.tryParse(value);

        if (port == null) {
          return;
        }

        ref.editNotifier
            .updateProxySettings(proxySettings?.copyWith(port: port));
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Port (*)',
        hintText: '8080',
      ),
    );
  }
}

class ProxyUsernameInput extends ConsumerStatefulWidget {
  const ProxyUsernameInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProxyUsernameInputState();
}

class _ProxyUsernameInputState extends ConsumerState<ProxyUsernameInput> {
  @override
  Widget build(BuildContext context) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    return BooruTextFormField(
      initialValue: proxySettings?.username,
      onChanged: (value) {
        ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(username: () => value),
        );
      },
      decoration: const InputDecoration(
        labelText: 'Username',
        hintText: 'username (optional)',
      ),
    );
  }
}

class ProxyPasswordInput extends ConsumerStatefulWidget {
  const ProxyPasswordInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProxyPasswordInputState();
}

class _ProxyPasswordInputState extends ConsumerState<ProxyPasswordInput> {
  @override
  Widget build(BuildContext context) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    return BooruTextFormField(
      initialValue: proxySettings?.password,
      onChanged: (value) {
        ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(password: () => value),
        );
      },
      decoration: const InputDecoration(
        labelText: 'Password',
        hintText: 'password (optional)',
      ),
    );
  }
}

class ProxyTypeOptionTile extends ConsumerWidget {
  const ProxyTypeOptionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      visualDensity: VisualDensity.compact,
      title: const Text('Proxy Type'),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: proxySettings?.type,
        onChanged: (value) => ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(type: value),
        ),
        items: ProxyType.values
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  switch (e) {
                    ProxyType.unknown => '<Select>',
                    ProxyType.http => 'HTTP(S)',
                    ProxyType.socks5 => 'SOCKS5',
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class EnableProxySwitch extends ConsumerWidget {
  const EnableProxySwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      title: const Text(
        'Proxy',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: proxySettings?.enable ?? false,
      onChanged: (value) => ref.editNotifier.updateProxySettings(
        proxySettings?.copyWith(enable: value),
      ),
    );
  }
}

enum TestProxyStatus {
  idle,
  checking,
  checkingPendingTimeout,
}

final testProxyProvider =
    NotifierProvider.autoDispose<TestProxyNotifier, TestProxyState>(
  TestProxyNotifier.new,
);

class TestProxyState extends Equatable {
  const TestProxyState(this.status, {this.cancelToken});

  final TestProxyStatus status;
  final CancelToken? cancelToken;

  TestProxyState copyWith({
    TestProxyStatus? status,
    CancelToken? cancelToken,
  }) {
    return TestProxyState(
      status ?? this.status,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props => [status, cancelToken];
}

const _kCheckProxyTimeout = Duration(seconds: 10);

class TestProxyNotifier extends AutoDisposeNotifier<TestProxyState> {
  @override
  TestProxyState build() {
    ref.onDispose(_cancel);

    return const TestProxyState(TestProxyStatus.idle);
  }

  Future<bool> check(
    ProxySettings proxySettings,
  ) async {
    final token = CancelToken();

    unawaited(
      Future.delayed(
        _kCheckProxyTimeout,
        () {
          // if still checking after a while, change status
          if (state.status == TestProxyStatus.checking) {
            state = state.copyWith(
              status: TestProxyStatus.checkingPendingTimeout,
            );
          }
        },
      ),
    );

    state = state.copyWith(
      status: TestProxyStatus.checking,
      cancelToken: token,
    );

    try {
      final dio = newGenericDio(
        baseUrl: 'https://example.com',
        proxySettings: proxySettings.copyWith(
          // Enable proxy for testing
          enable: true,
        ),
      );

      final res = await dio.get(
        '/',
        cancelToken: token,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      final statusCode = res.statusCode;

      if (statusCode == null) return false;

      return statusCode >= 200 && statusCode < 300;
    } on Exception catch (_) {
      return false;
    } finally {
      state = const TestProxyState(TestProxyStatus.idle);
    }
  }

  void _cancel() {
    final token = state.cancelToken;
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
  }

  void cancel() {
    _cancel();

    state = const TestProxyState(TestProxyStatus.idle);
  }
}

class TestProxyButton extends ConsumerWidget {
  const TestProxyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.proxySettingsTyped),
    );

    final notifier = ref.watch(testProxyProvider.notifier);
    final state = ref.watch(testProxyProvider);
    final status = state.status;

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        FilledButton(
          onPressed: proxySettings != null &&
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
                            ? 'Valid proxy settings'
                            : 'Failed to connect to proxy, please check your settings and try again',
                      ),
                    );
                  }
                }
              : null,
          child: switch (status) {
            TestProxyStatus.idle => const Text('Test Proxy'),
            _ => const Text('Checking...'),
          },
        ),
        if (status == TestProxyStatus.checkingPendingTimeout)
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Slow response? ',
                  ),
                  TextSpan(
                    text: 'Cancel',
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
