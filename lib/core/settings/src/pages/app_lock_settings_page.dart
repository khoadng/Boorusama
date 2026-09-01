// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/applock/applock.dart';
import '../../../../foundation/pincode/pincode.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/settings.dart';
import '../widgets/settings_page_scaffold.dart';

class AppLockSettingsPage extends ConsumerWidget {
  const AppLockSettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final appLock = context.t.settings.privacy.app_lock;
    final capabilities = ref.watch(appLockCapabilitiesProvider);

    return SettingsPageScaffold(
      title: Text(appLock.title),
      children: [
        KurumiSettingsTile<AppLockType>(
          title: Text(appLock.title),
          subtitle: Text(appLock.description),
          selectedOption: settings.appLockType,
          items: [
            AppLockType.none,
            AppLockType.pin,
            if (capabilities.deviceAuthentication) AppLockType.biometrics,
          ],
          optionBuilder: (value) => Text(appLockTypeLabel(context, value)),
          selectedOptionBuilder: (value) =>
              Text(appLockTypeLabel(context, value)),
          onChanged: (value) => _changeLockType(
            context,
            ref,
            settings,
            value,
          ),
        ),
        if (settings.appLockType.isPin)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(appLock.change_pin),
            subtitle: Text(appLock.change_pin_description),
            onTap: () => _changePin(context, ref),
          ),
        if (settings.appLockType.appLockEnabled)
          KurumiSettingsTile<int>(
            title: Text(appLock.lock_after),
            subtitle: Text(appLock.lock_after_description),
            selectedOption: settings.appLockTimeoutSeconds,
            items: _timeoutOptions,
            optionBuilder: (value) => Text(appLockTimeoutLabel(context, value)),
            selectedOptionBuilder: (value) =>
                Text(appLockTimeoutLabel(context, value)),
            onChanged: (value) {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .updateWith(
                    (settings) => settings.copyWith(
                      appLockTimeoutSeconds: value,
                    ),
                  );
            },
          ),
      ],
    );
  }
}

const _timeoutOptions = [
  0,
  30,
  60,
  300,
  900,
];

String appLockTypeLabel(BuildContext context, AppLockType type) {
  final appLock = context.t.settings.privacy.app_lock;

  return switch (type) {
    AppLockType.none => appLock.off,
    AppLockType.pin => appLock.pin,
    AppLockType.biometrics => appLock.device_authentication,
  };
}

String appLockTimeoutLabel(BuildContext context, int seconds) {
  final appLock = context.t.settings.privacy.app_lock;

  return switch (seconds) {
    0 => appLock.timeout_immediately,
    30 => appLock.timeout_seconds(seconds: seconds),
    60 => appLock.timeout_one_minute,
    _ when seconds % 60 == 0 => appLock.timeout_minutes(
      minutes: seconds ~/ 60,
    ),
    _ => appLock.timeout_seconds(seconds: seconds),
  };
}

String appLockSummary(BuildContext context, Settings settings) {
  final appLock = context.t.settings.privacy.app_lock;
  final type = appLockTypeLabel(context, settings.appLockType);

  if (!settings.appLockType.appLockEnabled) {
    return type;
  }

  return appLock.summary(
    type: type,
    timeout: appLockTimeoutLabel(context, settings.appLockTimeoutSeconds),
  );
}

Future<void> _changeLockType(
  BuildContext context,
  WidgetRef ref,
  Settings settings,
  AppLockType type,
) async {
  if (settings.appLockType == type) return;

  final notifier = ref.read(settingsNotifierProvider.notifier);
  final credentialRepository = ref.read(pinCredentialRepositoryProvider);
  final oldType = settings.appLockType;
  final wasPin = oldType.isPin;
  final wasDeviceAuthentication = oldType.isBiometric;

  if (oldType.appLockEnabled) {
    final verified = await _verifyCurrentLock(context, ref, oldType);
    if (!verified) return;
  }

  if (!context.mounted) return;

  switch (type) {
    case AppLockType.pin:
      final hadPin = await credentialRepository.hasPin();
      if (!context.mounted) return;

      final saved = await showPinSetupDialog(context, ref);
      if (!saved) return;

      final settingsSaved = await notifier.updateWith(
        (settings) => settings.copyWith(appLockType: type),
      );
      if (!settingsSaved && !hadPin) {
        await credentialRepository.clearPin();
      }
    case AppLockType.biometrics:
      final canUse = await ref.read(canUseBiometricLockProvider.future);
      if (!context.mounted) return;

      if (!canUse) {
        Kurumi.showErrorToast(
          context,
          context.t.settings.privacy.app_lock.biometric_not_available,
        );
        return;
      }

      final settingsSaved = await notifier.updateWith(
        (settings) => settings.copyWith(appLockType: type),
      );
      if (settingsSaved && wasPin) {
        await credentialRepository.clearPin();
      }
    case AppLockType.none:
      final saved = await notifier.updateWith(
        (settings) => settings.copyWith(appLockType: type),
      );
      if (saved && (wasPin || wasDeviceAuthentication)) {
        await credentialRepository.clearPin();
      }
  }
}

Future<void> _changePin(BuildContext context, WidgetRef ref) async {
  final type = ref.read(settingsProvider).appLockType;
  final verified = await _verifyCurrentLock(
    context,
    ref,
    type,
  );
  if (!verified || !context.mounted) return;

  final changed = await showPinSetupDialog(context, ref);
  if (!changed || !context.mounted) return;

  Kurumi.showSuccessToast(
    context,
    context.t.settings.privacy.app_lock.pin_updated,
  );
}

Future<bool> _verifyCurrentLock(
  BuildContext context,
  WidgetRef ref,
  AppLockType type,
) async {
  if (type.isPin) return showPinVerifyDialog(context, ref);
  if (!type.isBiometric) return true;

  try {
    return await startAuthenticate(
      ref.read(biometricsProvider),
      localizedReason: context.t.settings.privacy.app_lock.authenticate_reason,
    );
  } catch (_) {
    if (context.mounted) {
      Kurumi.showErrorToast(
        context,
        context.t.settings.privacy.app_lock.biometric_not_available,
      );
    }
    return false;
  }
}
