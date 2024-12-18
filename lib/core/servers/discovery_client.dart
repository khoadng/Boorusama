// Dart imports:

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bonsoir/bonsoir.dart';

class DiscoveryClient {
  DiscoveryClient({
    this.onError,
    this.onServiceFound,
    this.onServiceResolved,
    this.onServiceLost,
  });

  BonsoirDiscovery? _discovery;
  StreamSubscription? _discoverySubscription;
  final void Function(String message)? onError;
  final void Function(BonsoirService service)? onServiceFound;
  final void Function(BonsoirService service)? onServiceResolved;
  final void Function(BonsoirService service)? onServiceLost;

  Future<void> startDiscovery() async {
    try {
      _discovery = BonsoirDiscovery(type: '_boorusama._tcp');
      await _discovery?.ready;

      _discoverySubscription = _discovery?.eventStream?.listen((event) {
        switch (event.type) {
          case BonsoirDiscoveryEventType.discoveryServiceFound:
            final service = event.service;
            if (service != null) {
              onServiceFound?.call(service);
              service.resolve(_discovery!.serviceResolver);
            }
            break;
          case BonsoirDiscoveryEventType.discoveryServiceResolved:
            if (event.service != null) {
              onServiceResolved?.call(event.service!);
            }
            break;
          case BonsoirDiscoveryEventType.discoveryServiceLost:
            if (event.service != null) {
              onServiceLost?.call(event.service!);
            }
            break;
          default:
            onError?.call('Unknown discovery event: ${event.type}');
        }
      });

      await _discovery?.start();
    } catch (e) {
      onError?.call('Failed to start discovery: $e');
    }
  }

  void stopDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _discovery?.stop();
    _discovery = null;
  }

  bool get isDiscovering => _discovery != null;
}
