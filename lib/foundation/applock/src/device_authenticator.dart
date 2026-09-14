abstract interface class DeviceAuthenticator {
  Future<bool> get canCheckBiometrics;
  Future<bool> isDeviceSupported();

  Future<bool> authenticate({
    required String localizedReason,
  });
}
