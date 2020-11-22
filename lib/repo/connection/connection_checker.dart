import 'dart:async';

import 'package:connectivity/connectivity.dart';

class ConnectionChecker {

  Timer _timer;
  StreamController streamController = StreamController<ConnectivityResult>();
  Connectivity _connectivity = Connectivity();

  Stream<ConnectivityResult> get connectivityStream => streamController.stream;

  void checkConnectionStatus() {
    _timer = Timer.periodic(new Duration(milliseconds: 2000), (timer) async {
      final result = await _connectivity.checkConnectivity();
      streamController.sink.add(result);
    });
  }

  void dispose() {
    _timer.cancel();
    streamController.close();
  }

}