// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../widgets/enable_proxy_switch.dart';
import '../widgets/http_protocol_option_tile.dart';
import '../widgets/proxy_host_input.dart';
import '../widgets/proxy_password_input.dart';
import '../widgets/proxy_port_input.dart';
import '../widgets/proxy_type_option_tile.dart';
import '../widgets/proxy_username_input.dart';
import '../widgets/test_proxy_button.dart';

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
          SizedBox(height: 12),
          HttpProtocolOptionTile(),
          Divider(),
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
