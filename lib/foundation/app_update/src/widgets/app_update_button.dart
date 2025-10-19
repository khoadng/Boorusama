// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../providers.dart';
import '../types/update_status.dart';
import 'app_update_dialog.dart';

class AppUpdateButton extends ConsumerWidget {
  const AppUpdateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appUpdateStatusProvider)) {
      AsyncData(:final value) when value is UpdateAvailable =>
        RawAppUpdateButton(status: value),
      _ => const SizedBox.shrink(),
    };
  }
}

class RawAppUpdateButton extends StatelessWidget {
  const RawAppUpdateButton({
    required this.status,
    super.key,
  });

  final UpdateAvailable status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      splashRadius: 12,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          FontAwesomeIcons.arrowUp,
          size: 14,
          color: colorScheme.onError,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          routeSettings: const RouteSettings(
            name: 'app_update_notice',
          ),
          builder: (context) => AppUpdateDialog(status: status),
        );
      },
    );
  }
}
