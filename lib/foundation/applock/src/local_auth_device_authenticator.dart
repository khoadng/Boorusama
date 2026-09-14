// Package imports:
import 'package:local_auth/local_auth.dart';

// Project imports:
import 'device_authenticator.dart';

final class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  LocalAuthDeviceAuthenticator({
    LocalAuthentication? localAuthentication,
  }) : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> get canCheckBiometrics =>
      _localAuthentication.canCheckBiometrics;

  @override
  Future<bool> isDeviceSupported() => _localAuthentication.isDeviceSupported();

  @override
  Future<bool> authenticate({required String localizedReason}) =>
      _localAuthentication.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
      );
}
