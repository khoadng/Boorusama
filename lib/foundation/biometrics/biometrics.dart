// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricsProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final biometricDeviceSupportProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(biometricsProvider);
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  return canAuthenticate;
});

final biometricEnrolledProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(biometricsProvider);

  final availableBiometrics = await auth.getAvailableBiometrics();

  return availableBiometrics.isNotEmpty;
});

final canUseBiometricLockProvider = FutureProvider<bool>((ref) async {
  final hardwareSupport =
      await ref.watch(biometricDeviceSupportProvider.future);

  if (!hardwareSupport) return false;

  final isEnrolled = await ref.watch(biometricEnrolledProvider.future);

  return isEnrolled;
});

Future<bool> startAuthenticate(LocalAuthentication localAuth) async {
  final didAuthenticate =
      await localAuth.authenticate(localizedReason: 'Please authenticate');

  return didAuthenticate;
}
