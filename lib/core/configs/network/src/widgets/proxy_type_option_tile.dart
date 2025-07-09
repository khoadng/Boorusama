// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../proxy/proxy.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class ProxyTypeOptionTile extends ConsumerWidget {
  const ProxyTypeOptionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      visualDensity: VisualDensity.compact,
      title: Text('Proxy Type'.hc),
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
                    ProxyType.unknown => '<Select>'.hc,
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
