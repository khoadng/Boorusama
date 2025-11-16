// Package imports:
import 'package:permission_handler/permission_handler.dart';

abstract interface class LocalNetworkPermissionHandler {
  Future<PermissionStatus> check();
  Future<PermissionStatus> request();
}

extension LocalNetworkPermissionHandlerX on LocalNetworkPermissionHandler {
  Future<bool> isGranted() async {
    final status = await check();
    return status == PermissionStatus.granted;
  }

  Future<bool> isPermanentlyDenied() async {
    final status = await check();
    return status == PermissionStatus.permanentlyDenied;
  }

  Future<bool> requestIfNotGranted() async {
    final status = await check();

    if (status == PermissionStatus.granted) {
      return true;
    }

    if (status == PermissionStatus.permanentlyDenied) {
      return false;
    }

    final result = await request();
    return result == PermissionStatus.granted;
  }
}

final class DefaultLocalNetworkPermissionHandler
    implements LocalNetworkPermissionHandler {
  const DefaultLocalNetworkPermissionHandler();

  @override
  Future<PermissionStatus> check() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;
}

final class MockLocalNetworkPermissionHandler
    implements LocalNetworkPermissionHandler {
  var _status = PermissionStatus.denied;

  @override
  Future<PermissionStatus> check() async => _status;
  @override
  Future<PermissionStatus> request() async {
    // ignore: join_return_with_assignment
    _status = PermissionStatus.granted;
    return _status;
  }
}
