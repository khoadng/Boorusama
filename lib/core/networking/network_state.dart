sealed class NetworkState {}

final class NetworkInitialState extends NetworkState {}

final class NetworkLoadingState extends NetworkState {}

final class NetworkConnectedState extends NetworkState {}

final class NetworkDisconnectedState extends NetworkState {}
