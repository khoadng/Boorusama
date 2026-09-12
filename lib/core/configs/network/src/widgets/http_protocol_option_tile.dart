// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../http/configs/types.dart';
import '../../../create/providers.dart';

class HttpProtocolOptionTile extends ConsumerWidget {
  const HttpProtocolOptionTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkSettings = ref.watch(editBooruConfigNetworkProvider);

    final currentProtocol =
        networkSettings.httpSettings?.protocolOption ?? HttpProtocolOption.auto;

    return KurumiSettingsTile<HttpProtocolOption>(
      padding: const EdgeInsets.only(left: 4),
      visualDensity: VisualDensity.compact,
      optionAlignment: AlignmentDirectional.centerStart,
      title: Text(context.t.booru.network.http.protocol),
      subtitle: Text(context.t.booru.network.http.protocol_description),
      selectedOption: currentProtocol,
      onChanged: (value) {
        final newHttpSettings =
            (networkSettings.httpSettings ?? const HttpSettings()).copyWith(
              protocol: () => value.toData(),
            );

        final newNetworkSettings = networkSettings.copyWith(
          httpSettings: () => newHttpSettings,
        );

        ref.editNotifier.updateNetworkSettings(newNetworkSettings);
      },
      items: HttpProtocolOption.values,
      optionBuilder: (e) => Text(
        switch (e) {
          HttpProtocolOption.auto => 'Auto',
          HttpProtocolOption.https1_1 => 'HTTPS/1.1',
          HttpProtocolOption.https2_0 => 'HTTPS/2.0',
        },
      ),
    );
  }
}
