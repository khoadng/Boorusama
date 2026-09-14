// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'app_lock_capabilities.dart';
import 'device_authenticator.dart';

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>(
  (_) => throw UnimplementedError(),
  name: 'deviceAuthenticatorProvider',
);

final biometricDeviceSupportProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(deviceAuthenticatorProvider);
  final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  return canAuthenticate;
});

final canUseBiometricLockProvider = FutureProvider<bool>((ref) async {
  if (!ref.watch(appLockCapabilitiesProvider).deviceAuthentication) {
    return false;
  }

  final hardwareSupport = await ref.watch(
    biometricDeviceSupportProvider.future,
  );

  return hardwareSupport;
});

Future<bool> startAuthenticate(
  DeviceAuthenticator deviceAuthenticator, {
  required String localizedReason,
}) async {
  final didAuthenticate = await deviceAuthenticator.authenticate(
    localizedReason: localizedReason,
  );

  return didAuthenticate;
}
