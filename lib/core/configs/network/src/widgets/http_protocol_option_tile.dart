// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../http/configs/types.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class HttpProtocolOptionTile extends ConsumerWidget {
  const HttpProtocolOptionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkSettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.networkSettingsTyped),
    );

    final currentProtocol =
        networkSettings?.httpSettings?.protocolOption ??
        HttpProtocolOption.auto;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      visualDensity: VisualDensity.compact,
      title: Text(
        context.t.booru.network.http.protocol,
      ),
      subtitle: Text(context.t.booru.network.http.protocol_description),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: currentProtocol,
        onChanged: (value) {
          if (value == null) return;

          final newHttpSettings =
              (networkSettings?.httpSettings ?? const HttpSettings()).copyWith(
                protocol: () => value.toData(),
              );

          final newNetworkSettings =
              (networkSettings ?? const NetworkSettings()).copyWith(
                httpSettings: () => newHttpSettings,
              );

          ref.editNotifier.updateNetworkSettings(newNetworkSettings);
        },
        items: HttpProtocolOption.values
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  switch (e) {
                    HttpProtocolOption.auto => 'Auto',
                    HttpProtocolOption.https1_1 => 'HTTPS/1.1',
                    HttpProtocolOption.https2_0 => 'HTTPS/2.0',
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
