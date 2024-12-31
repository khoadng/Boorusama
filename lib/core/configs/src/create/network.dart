// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../proxy/proxy.dart';
import '../../../widgets/widgets.dart';
import '../../manage.dart';
import 'providers.dart';
import 'widgets.dart';

class BooruConfigNetworkView extends ConsumerWidget {
  const BooruConfigNetworkView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkConfigKey = ref.watch(_networkConfigKeyProvider);

    return SingleChildScrollView(
      key: ValueKey(networkConfigKey),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BooruConfigSettingsHeader(label: 'Proxy'),
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
          ClearAllProxyDataButton(),
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
        labelText: 'Host or IP',
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
        labelText: 'Port',
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
        hintText: 'username',
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
        hintText: 'password',
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
      contentPadding: EdgeInsets.zero,
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
                    _ => e.name.toUpperCase(),
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
      title: const Text('Use Proxy'),
      value: proxySettings?.enable ?? false,
      onChanged: (value) => ref.editNotifier.updateProxySettings(
        proxySettings?.copyWith(enable: value),
      ),
    );
  }
}

final _networkConfigKeyProvider = StateProvider<int>((ref) {
  return 0;
});

class ClearAllProxyDataButton extends ConsumerWidget {
  const ClearAllProxyDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = ref.watch(_networkConfigKeyProvider);

    return FilledButton(
      onPressed: () {
        ref.editNotifier.updateProxySettings(null);
        ref.read(_networkConfigKeyProvider.notifier).state = currentKey + 1;
      },
      child: const Text('Clear all proxy data'),
    );
  }
}
