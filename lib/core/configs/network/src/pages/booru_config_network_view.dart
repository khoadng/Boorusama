// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/data.dart';
import '../../../../settings/widgets.dart';
import '../widgets/enable_proxy_switch.dart';
import '../widgets/http_protocol_option_tile.dart';
import '../widgets/media_host_overrides_section.dart';
import '../widgets/proxy_host_input.dart';
import '../widgets/proxy_password_input.dart';
import '../widgets/proxy_port_input.dart';
import '../widgets/proxy_type_option_tile.dart';
import '../widgets/proxy_username_input.dart';
import '../widgets/skip_certificate_verification_tile.dart';
import '../widgets/test_proxy_button.dart';

class BooruConfigNetworkView extends ConsumerWidget {
  const BooruConfigNetworkView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const HttpProtocolOptionTile(),
          const SkipCertificateVerificationTile(),
          const Divider(),
          const EnableProxySwitch(),
          const ProxyTypeOptionTile(),
          const SizedBox(height: 12),
          const ProxyHostInput(),
          const SizedBox(height: 12),
          const ProxyPortInput(),
          const SizedBox(height: 12),
          const ProxyUsernameInput(),
          const SizedBox(height: 12),
          const ProxyPasswordInput(),
          const SizedBox(height: 12),
          const TestProxyButton(),
          const Divider(),
          SettingAnchor(
            id: SettingsIndex.network.mediaHosts.id,
            child: const MediaHostOverridesSection(),
          ),
        ],
      ),
    );
  }
}
