// Project imports:
import 'sync_service.dart';

/// Events emitted by the sync client.
sealed class SyncEvent {}

class SyncConfirmedEvent extends SyncEvent {}

class SyncResetEvent extends SyncEvent {}

class SyncDisconnectedEvent extends SyncEvent {}

class SyncErrorEvent extends SyncEvent {
  SyncErrorEvent(this.message);
  final String message;
}

/// Abstract interface for sync client operations.
abstract class SyncClientRepo {
  Future<StageToHubResult> stageToHub({String? existingClientId});
  Future<PullFromHubResult> pullFromHub({String? clientId});
  Stream<SyncEvent> get events;
  void disconnect();
  void dispose();
}
