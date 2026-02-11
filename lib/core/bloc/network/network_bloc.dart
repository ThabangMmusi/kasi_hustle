import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/connectivity_service.dart';

abstract class NetworkEvent {}

class NetworkNotify extends NetworkEvent {
  final bool isConnected;
  NetworkNotify({this.isConnected = false});
}

class NetworkObserve extends NetworkEvent {}

abstract class NetworkState {}

class NetworkInitial extends NetworkState {}

class NetworkSuccess extends NetworkState {}

class NetworkFailure extends NetworkState {}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final ConnectivityService _connectivityService;

  NetworkBloc(this._connectivityService) : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  void _observe(NetworkObserve event, Emitter<NetworkState> emit) {
    _connectivityService.isConnected.listen((isConnected) {
      add(NetworkNotify(isConnected: isConnected));
    });
  }

  void _notifyStatus(NetworkNotify event, Emitter<NetworkState> emit) {
    event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
  }
}
