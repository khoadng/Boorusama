// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class NetworkEvent {}

class ConnectedEvent extends NetworkEvent {}

class DisconnectedEvent extends NetworkEvent {}

@immutable
abstract class NetworkState {}

class NetworkInitialState extends NetworkState {}

class NetworkConnectedState extends NetworkState {}

class NetworkDisconnectedState extends NetworkState {}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {

  NetworkBloc() : super(NetworkInitialState()) {
    on<ConnectedEvent>((event, emit) => emit(NetworkConnectedState()));
    on<DisconnectedEvent>((event, emit) => emit(NetworkDisconnectedState()));

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        add(ConnectedEvent());
      } else {
        add(DisconnectedEvent());
      }
    });
  }
  StreamSubscription? subscription;
  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
