import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class ConnectivityBloc extends Bloc {

  Timer _timer;

  final _connectivityController = StreamController<ConnectivityResult>();
  final _networkErrorController = StreamController<bool>();

  Sink<ConnectivityResult> get _inConnectivityController => _connectivityController.sink;
  Sink<bool> get inNetworkErrorController => _networkErrorController.sink;
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  Stream<bool> get networkErrorStream => _networkErrorController.stream;

  void checkConnectionStatus() {
    final connectivity = Connectivity();
    _timer = Timer.periodic(new Duration(seconds: 2), (timer) async {
      final result = await connectivity.checkConnectivity();
      _inConnectivityController.add(result);
    });
  }


  @override
  void dispose() {
    _connectivityController.close();
    _networkErrorController.close();
    _timer.cancel();
  }

}