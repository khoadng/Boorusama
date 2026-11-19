abstract interface class DeviceAuthenticator {
  Future<bool> isDeviceSupported();

  Future<bool> authenticate({
    required String localizedReason,
  });
}
