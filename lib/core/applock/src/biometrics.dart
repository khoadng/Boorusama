// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricsProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final biometricDeviceSupportProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(biometricsProvider);
  final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  return canAuthenticate;
});

final canUseBiometricLockProvider = FutureProvider<bool>((ref) async {
  final hardwareSupport =
      await ref.watch(biometricDeviceSupportProvider.future);

  return hardwareSupport;
});

Future<bool> startAuthenticate(LocalAuthentication localAuth) async {
  final didAuthenticate =
      await localAuth.authenticate(localizedReason: 'Please authenticate');

  return didAuthenticate;
}
