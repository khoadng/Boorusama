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

class SkipCertificateVerificationTile extends ConsumerWidget {
  const SkipCertificateVerificationTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkSettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.networkSettingsTyped),
    );

    final skipCertVerification =
        networkSettings?.httpSettings?.skipCertificateVerification ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.only(left: 4),
          visualDensity: VisualDensity.compact,
          title: Text(context.t.booru.network.http.skip_cert_verification),
          subtitle: Text(
            context.t.booru.network.http.skip_cert_verification_description,
          ),
          value: skipCertVerification,
          onChanged: (value) {
            final newHttpSettings =
                (networkSettings?.httpSettings ?? const HttpSettings())
                    .copyWith(
                      skipCertificateVerification: () => value,
                    );

            final newNetworkSettings =
                (networkSettings ?? const NetworkSettings()).copyWith(
                  httpSettings: () => newHttpSettings,
                );

            ref.editNotifier.updateNetworkSettings(newNetworkSettings);
          },
        ),
        if (skipCertVerification)
          WarningContainer(
            margin: const EdgeInsets.only(top: 8),
            title: context.t.booru.network.http.skip_cert_verification_warning_title,
            contentBuilder: (context) => Text(
              context.t.booru.network.http.skip_cert_verification_warning,
            ),
          ),
      ],
    );
  }
}
