import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class ConnectivityBloc extends Bloc {

  Timer _timer;

  final _connectivityController = StreamController<ConnectivityResult>();
  final _networkErrorController = StreamController<bool>();

  // Vars
  bool _isNetworkError;

  Sink<ConnectivityResult> get _inConnectivityController => _connectivityController.sink;
  Sink<bool> get _inNetworkErrorController => _networkErrorController.sink;
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  Stream<bool> get networkErrorStream => _networkErrorController.stream;

  void checkConnectionStatus() {
    final connectivity = Connectivity();
    _timer = Timer.periodic(new Duration(seconds: 2), (timer) async {
      final result = await connectivity.checkConnectivity();
      _inConnectivityController.add(result);
      _reactToConnectionChange(result);
    });
  }

  void _reactToConnectionChange(ConnectivityResult result) {
    if (!(result == ConnectivityResult.none)) {
      // Internet connection is ON
      if (_isNetworkError) {
        _isNetworkError = false;
        _inNetworkErrorController.add(false);
      }
    }
  }

  void setIsNetworkError(bool error) {
    _isNetworkError = error;
    _inNetworkErrorController.add(error);
  }

  @override
  void dispose() {
    _connectivityController.close();
    _networkErrorController.close();
    _timer.cancel();
  }

}